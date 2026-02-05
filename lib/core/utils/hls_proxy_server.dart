// lib/core/utils/hls_proxy_server.dart

import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:http/http.dart' as http;

class HlsProxyServer {
  HttpServer? _server;
  static const int port = 8080;
  
  bool get isRunning => _server != null;
  
  /// Start the proxy server
  Future<void> start() async {
    if (isRunning) {
      print('Proxy server already running on port $port');
      return;
    }
    
    try {
      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(_handleRequest);
      
      _server = await shelf_io.serve(
        handler,
        InternetAddress.loopbackIPv4,
        port,
      );
      
      print('HLS Proxy server started on http://localhost:$port');
    } catch (e) {
      print('Failed to start proxy server: $e');
      rethrow;
    }
  }
  
  /// Stop the proxy server
  Future<void> stop() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
      print('Proxy server stopped');
    }
  }
  
  /// Main request handler
  Future<Response> _handleRequest(Request request) async {
    try {
      // Extract target URL from query parameter
      final url = request.url.queryParameters['url'];
      
      if (url == null || url.isEmpty) {
        return Response.badRequest(body: 'Missing URL parameter');
      }
      
      // Check if this is a master playlist or media playlist
      if (url.contains('.m3u8')) {
        return await _handlePlaylistRequest(url);
      } else {
        // For TS segments, just proxy them
        return await _proxyRequest(url);
      }
    } catch (e) {
      print('Proxy error: $e');
      return Response.internalServerError(body: 'Proxy error: $e');
    }
  }
  
  /// Handle M3U8 playlist requests (ad filtering)
  Future<Response> _handlePlaylistRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        return Response(response.statusCode, body: response.body);
      }
      
      // Parse and filter the playlist
      final filteredPlaylist = _filterPlaylist(response.body, url);
      
      return Response.ok(
        filteredPlaylist,
        headers: {
          'Content-Type': 'application/vnd.apple.mpegurl',
          'Access-Control-Allow-Origin': '*',
        },
      );
    } catch (e) {
      print('Playlist request error: $e');
      return Response.internalServerError(body: 'Failed to fetch playlist');
    }
  }
  
  /// Filter out ad segments from playlist
  String _filterPlaylist(String playlist, String baseUrl) {
    final lines = playlist.split('\n');
    final filteredLines = <String>[];
    bool skipNext = false;
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      // Skip empty lines
      if (line.isEmpty) {
        filteredLines.add(line);
        continue;
      }
      
      // Detect ad markers (Twitch-specific)
      if (_isAdMarker(line)) {
        skipNext = true;
        continue;
      }
      
      // Skip segment if it was marked as ad
      if (skipNext && !line.startsWith('#')) {
        skipNext = false;
        continue;
      }
      
      // Handle variant playlists (master playlist)
      if (line.startsWith('#EXT-X-STREAM-INF')) {
        filteredLines.add(line);
        
        // Next line is the variant URL
        if (i + 1 < lines.length) {
          i++;
          final variantUrl = lines[i].trim();
          
          // Rewrite URL to go through proxy
          final proxiedUrl = _rewriteUrl(variantUrl, baseUrl);
          filteredLines.add(proxiedUrl);
        }
        continue;
      }
      
      // Handle media segments
      if (!line.startsWith('#') && line.contains('.ts')) {
        // Rewrite segment URLs to absolute URLs (no proxy needed for segments)
        final absoluteUrl = _makeAbsoluteUrl(line, baseUrl);
        filteredLines.add(absoluteUrl);
        continue;
      }
      
      // Keep all other lines
      filteredLines.add(line);
    }
    
    return filteredLines.join('\n');
  }
  
  /// Detect ad markers in playlist
  bool _isAdMarker(String line) {
    // Twitch ad detection patterns
    final adPatterns = [
      '#EXT-X-DISCONTINUITY-SEQUENCE',
      '#EXT-X-DATERANGE',
      'stitched-ad',
      'amazon-ads',
      '#EXT-X-PROGRAM-DATE-TIME', // Sometimes used for ad insertion
    ];
    
    for (final pattern in adPatterns) {
      if (line.contains(pattern)) {
        // Additional check for stitched ads
        if (line.contains('CLASS="stitched-ad"')) {
          return true;
        }
        
        // Check for Amazon ad insertion
        if (line.contains('amazon')) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Rewrite relative URL to go through proxy
  String _rewriteUrl(String url, String baseUrl) {
    final absoluteUrl = _makeAbsoluteUrl(url, baseUrl);
    final encoded = Uri.encodeComponent(absoluteUrl);
    return 'http://localhost:$port/proxy?url=$encoded';
  }
  
  /// Convert relative URL to absolute
  String _makeAbsoluteUrl(String url, String baseUrl) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    final baseUri = Uri.parse(baseUrl);
    final resolvedUri = baseUri.resolve(url);
    return resolvedUri.toString();
  }
  
  /// Simple proxy for direct requests (TS segments)
  Future<Response> _proxyRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      return Response(
        response.statusCode,
        body: response.bodyBytes,
        headers: {
          'Content-Type': response.headers['content-type'] ?? 'application/octet-stream',
          'Access-Control-Allow-Origin': '*',
        },
      );
    } catch (e) {
      print('Proxy request error: $e');
      return Response.internalServerError(body: 'Proxy error');
    }
  }
}

// ============ SINGLETON INSTANCE ============

final hlsProxyServer = HlsProxyServer();
