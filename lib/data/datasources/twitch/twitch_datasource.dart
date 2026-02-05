// lib/data/datasources/twitch/twitch_datasource.dart

import 'package:dio/dio.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:xtra_neo/core/constants/api_constants.dart';
import 'dart:convert';

class TwitchDataSource {
  final Dio _dio;
  oauth2.Client? _oauthClient;
  
  TwitchDataSource({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = ApiConstants.twitchBaseUrl;
    _dio.options.headers = ApiConstants.twitchHeaders;
  }
  
  // ============ AUTHENTICATION ============
  
  /// Get OAuth2 authorization URL
  Uri getAuthorizationUrl() {
    final authorizationEndpoint = Uri.parse('${ApiConstants.twitchAuthUrl}/authorize');
    final tokenEndpoint = Uri.parse('${ApiConstants.twitchAuthUrl}/token');
    
    final grant = oauth2.AuthorizationCodeGrant(
      ApiConstants.twitchClientId,
      authorizationEndpoint,
      tokenEndpoint,
      secret: ApiConstants.twitchClientSecret,
    );
    
    return grant.getAuthorizationUrl(
      Uri.parse(ApiConstants.twitchRedirectUri),
      scopes: [
        'user:read:email',
        'user:read:follows',
        'chat:read',
        'chat:edit',
        'user:read:subscriptions',
      ],
    );
  }
  
  /// Exchange authorization code for access token
  Future<Map<String, dynamic>> authenticate(String code) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.twitchAuthUrl}/token',
        data: {
          'client_id': ApiConstants.twitchClientId,
          'client_secret': ApiConstants.twitchClientSecret,
          'code': code,
          'grant_type': 'authorization_code',
          'redirect_uri': ApiConstants.twitchRedirectUri,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      
      return response.data;
    } catch (e) {
      throw Exception('Twitch authentication failed: $e');
    }
  }
  
  /// Refresh access token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.twitchAuthUrl}/token',
        data: {
          'client_id': ApiConstants.twitchClientId,
          'client_secret': ApiConstants.twitchClientSecret,
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      
      return response.data;
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }
  
  /// Validate current token
  Future<bool> validateToken(String accessToken) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.twitchAuthUrl}/validate',
        options: Options(
          headers: {'Authorization': 'OAuth $accessToken'},
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // ============ STREAM DATA ============
  
  /// Get stream URL with ad-blocking proxy
  Future<String> getStreamUrl(String username, {String quality = 'best'}) async {
    try {
      // Get access token for stream (GQL method)
      final playbackToken = await _getPlaybackAccessToken(username);
      
      // Build HLS URL with proxy bypass
      final hlsUrl = await _buildProxiedHlsUrl(
        username,
        playbackToken['token'],
        playbackToken['signature'],
        quality,
      );
      
      return hlsUrl;
    } catch (e) {
      throw Exception('Failed to get stream URL: $e');
    }
  }
  
  /// Get playback access token using GraphQL (bypass ads)
  Future<Map<String, dynamic>> _getPlaybackAccessToken(String username) async {
    const query = '''
      {
        streamPlaybackAccessToken(
          channelName: "%s",
          params: {
            platform: "android",
            playerBackend: "mediaplayer",
            playerType: "site"
          }
        ) {
          value
          signature
        }
      }
    ''';
    
    try {
      final response = await _dio.post(
        ApiConstants.twitchGqlUrl,
        data: {
          'query': query.replaceFirst('%s', username),
        },
        options: Options(
          headers: {
            'Client-ID': ApiConstants.twitchClientId,
            'Content-Type': 'application/json',
          },
        ),
      );
      
      final data = response.data['data']['streamPlaybackAccessToken'];
      return {
        'token': data['value'],
        'signature': data['signature'],
      };
    } catch (e) {
      throw Exception('Failed to get playback token: $e');
    }
  }
  
  /// Build proxied HLS URL (routes through local proxy for ad removal)
  Future<String> _buildProxiedHlsUrl(
    String username,
    String token,
    String signature,
    String quality,
  ) async {
    final usherUrl = '${ApiConstants.twitchUsherUrl}/api/channel/hls/$username.m3u8';
    final params = {
      'token': token,
      'sig': signature,
      'allow_source': 'true',
      'allow_audio_only': 'true',
      'player': 'twitchweb',
      'playlist_include_framerate': 'true',
    };
    
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    final rawUrl = '$usherUrl?$queryString';
    
    // Return proxied URL (local proxy will strip ad segments)
    return '${ApiConstants.proxyBaseUrl}/proxy?url=${Uri.encodeComponent(rawUrl)}';
  }
  
  // ============ CHANNEL DATA ============
  
  /// Get channel info
  Future<Map<String, dynamic>> getChannel(String username) async {
    try {
      final response = await _dio.get(
        '/users',
        queryParameters: {'login': username},
      );
      
      if (response.data['data'].isEmpty) {
        throw Exception('Channel not found');
      }
      
      return response.data['data'][0];
    } catch (e) {
      throw Exception('Failed to get channel: $e');
    }
  }
  
  /// Get live stream info
  Future<Map<String, dynamic>?> getStream(String userId) async {
    try {
      final response = await _dio.get(
        '/streams',
        queryParameters: {'user_id': userId},
      );
      
      if (response.data['data'].isEmpty) {
        return null; // Stream offline
      }
      
      return response.data['data'][0];
    } catch (e) {
      throw Exception('Failed to get stream: $e');
    }
  }
  
  /// Get followed channels
  Future<List<Map<String, dynamic>>> getFollowedChannels(String userId) async {
    try {
      final response = await _dio.get(
        '/channels/followed',
        queryParameters: {
          'user_id': userId,
          'first': 100,
        },
      );
      
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get followed channels: $e');
    }
  }
  
  // ============ CHAT ============
  
  /// Get chat badges for a channel
  Future<Map<String, dynamic>> getChatBadges(String channelId) async {
    try {
      final response = await _dio.get(
        '/chat/badges',
        queryParameters: {'broadcaster_id': channelId},
      );
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to get chat badges: $e');
    }
  }
  
  /// Get channel emotes
  Future<List<Map<String, dynamic>>> getChannelEmotes(String channelId) async {
    try {
      final response = await _dio.get(
        '/chat/emotes',
        queryParameters: {'broadcaster_id': channelId},
      );
      
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get emotes: $e');
    }
  }
}
