// lib/data/datasources/kick/kick_datasource.dart

import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:xtra_neo/core/constants/api_constants.dart';
import 'dart:convert';

class KickDataSource {
  final Dio _dio;
  WebSocketChannel? _chatChannel;
  
  KickDataSource({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = ApiConstants.kickBaseUrl;
    _dio.options.headers = ApiConstants.kickHeaders;
  }
  
  // ============ STREAM DATA ============
  
  /// Get channel data and extract stream URL
  Future<Map<String, dynamic>> getChannel(String username) async {
    try {
      final response = await _dio.get('/channels/$username');
      
      if (response.statusCode != 200) {
        throw Exception('Channel not found');
      }
      
      final channelData = response.data;
      
      return {
        'id': channelData['id'],
        'username': channelData['slug'],
        'display_name': channelData['user']['username'],
        'avatar': channelData['user']['profile_pic'],
        'banner': channelData['banner']?['responsive'] ?? '',
        'followers': channelData['followers_count'] ?? 0,
        'description': channelData['user']['bio'] ?? '',
        'is_live': channelData['livestream'] != null,
        'livestream': channelData['livestream'],
      };
    } catch (e) {
      throw Exception('Failed to get Kick channel: $e');
    }
  }
  
  /// Get M3U8 stream URL from channel data
  Future<String> getStreamUrl(String username) async {
    try {
      final channelData = await getChannel(username);
      
      if (!channelData['is_live']) {
        throw Exception('Channel is offline');
      }
      
      final livestream = channelData['livestream'];
      
      // Kick provides direct M3U8 URL in API response
      final playbackUrl = livestream['playback_url'];
      
      if (playbackUrl == null || playbackUrl.isEmpty) {
        throw Exception('No playback URL available');
      }
      
      return playbackUrl;
    } catch (e) {
      throw Exception('Failed to get Kick stream URL: $e');
    }
  }
  
  /// Get stream info (viewers, title, etc.)
  Future<Map<String, dynamic>?> getStreamInfo(String username) async {
    try {
      final channelData = await getChannel(username);
      
      if (!channelData['is_live']) {
        return null;
      }
      
      final livestream = channelData['livestream'];
      
      return {
        'id': livestream['id'],
        'title': livestream['session_title'] ?? 'Untitled Stream',
        'category': livestream['categories']?[0]?['name'] ?? 'No Category',
        'viewers': livestream['viewer_count'] ?? 0,
        'thumbnail': livestream['thumbnail']?['url'] ?? '',
        'started_at': livestream['created_at'],
        'language': livestream['language'] ?? 'en',
      };
    } catch (e) {
      throw Exception('Failed to get stream info: $e');
    }
  }
  
  /// Alternative method: Scrape HTML page for stream URL
  Future<String> scrapeStreamUrl(String username) async {
    try {
      final response = await _dio.get(
        'https://kick.com/$username',
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36',
          },
        ),
      );
      
      final document = html_parser.parse(response.data);
      
      // Kick embeds data in script tags
      final scriptTags = document.querySelectorAll('script');
      
      for (final script in scriptTags) {
        final content = script.text;
        
        // Look for playback_url in embedded JSON
        if (content.contains('playback_url')) {
          final regex = RegExp(r'"playback_url":"([^"]+)"');
          final match = regex.firstMatch(content);
          
          if (match != null) {
            return match.group(1)!.replaceAll(r'\/', '/');
          }
        }
      }
      
      throw Exception('Could not extract stream URL from HTML');
    } catch (e) {
      throw Exception('Failed to scrape stream URL: $e');
    }
  }
  
  // ============ CHAT ============
  
  /// Connect to Kick chat via WebSocket (Pusher protocol)
  Future<WebSocketChannel> connectToChat(String channelId) async {
    try {
      final wsUrl = '${ApiConstants.kickChatUrl}?protocol=7&client=js&version=7.0.3';
      
      _chatChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Subscribe to chat channel
      await Future.delayed(const Duration(seconds: 1));
      
      final subscribeMessage = jsonEncode({
        'event': 'pusher:subscribe',
        'data': {
          'auth': '',
          'channel': 'chatrooms.$channelId.v2',
        },
      });
      
      _chatChannel!.sink.add(subscribeMessage);
      
      return _chatChannel!;
    } catch (e) {
      throw Exception('Failed to connect to Kick chat: $e');
    }
  }
  
  /// Get chat room ID from channel
  Future<String> getChatRoomId(String username) async {
    try {
      final channelData = await getChannel(username);
      return channelData['id'].toString();
    } catch (e) {
      throw Exception('Failed to get chat room ID: $e');
    }
  }
  
  /// Send chat message (requires authentication - not implemented in basic version)
  Future<void> sendChatMessage(String channelId, String message) async {
    // Note: Sending messages requires authentication
    // This is a placeholder for future implementation
    throw UnimplementedError('Chat sending requires authentication');
  }
  
  /// Disconnect from chat
  void disconnectChat() {
    _chatChannel?.sink.close();
    _chatChannel = null;
  }
  
  // ============ SEARCH & DISCOVERY ============
  
  /// Search for channels
  Future<List<Map<String, dynamic>>> searchChannels(String query) async {
    try {
      final response = await _dio.get(
        '/search/channels',
        queryParameters: {'query': query},
      );
      
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to search channels: $e');
    }
  }
  
  /// Get trending/featured streams
  Future<List<Map<String, dynamic>>> getFeaturedStreams() async {
    try {
      final response = await _dio.get('/channels/featured');
      
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get featured streams: $e');
    }
  }
  
  /// Get category/game streams
  Future<List<Map<String, dynamic>>> getCategoryStreams(String categorySlug) async {
    try {
      final response = await _dio.get('/categories/$categorySlug/livestreams');
      
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get category streams: $e');
    }
  }
}
