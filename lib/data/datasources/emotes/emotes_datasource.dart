// lib/data/datasources/emotes/emotes_datasource.dart

import 'package:dio/dio.dart';
import 'package:xtra_neo/core/constants/api_constants.dart';

class EmotesDataSource {
  final Dio _dio;
  
  // Cache para emotes
  final Map<String, List<Emote>> _emoteCache = {};
  
  EmotesDataSource({Dio? dio}) : _dio = dio ?? Dio();
  
  // ============ 7TV EMOTES ============
  
  Future<List<Emote>> get7TVEmotes(String channelId) async {
    final cacheKey = '7tv_$channelId';
    
    if (_emoteCache.containsKey(cacheKey)) {
      return _emoteCache[cacheKey]!;
    }
    
    try {
      final response = await _dio.get(
        '${ApiConstants.seventvBaseUrl}/users/twitch/$channelId',
      );
      
      final emotes = <Emote>[];
      final emoteSet = response.data['emote_set'];
      
      if (emoteSet != null && emoteSet['emotes'] != null) {
        for (final emote in emoteSet['emotes']) {
          emotes.add(Emote(
            name: emote['name'],
            url: _build7TVUrl(emote['id']),
            provider: EmoteProvider.sevenTV,
            isZeroWidth: emote['flags'] == 1,
          ));
        }
      }
      
      _emoteCache[cacheKey] = emotes;
      return emotes;
    } catch (e) {
      print('Failed to load 7TV emotes: $e');
      return [];
    }
  }
  
  String _build7TVUrl(String emoteId) {
    // 7TV CDN URLs
    return 'https://cdn.7tv.app/emote/$emoteId/2x.webp';
  }
  
  // ============ BTTV EMOTES ============
  
  Future<List<Emote>> getBTTVEmotes(String channelId) async {
    final cacheKey = 'bttv_$channelId';
    
    if (_emoteCache.containsKey(cacheKey)) {
      return _emoteCache[cacheKey]!;
    }
    
    try {
      // Get channel emotes
      final channelResponse = await _dio.get(
        '${ApiConstants.bttvBaseUrl}/cached/users/twitch/$channelId',
      );
      
      // Get global emotes
      final globalResponse = await _dio.get(
        '${ApiConstants.bttvBaseUrl}/cached/emotes/global',
      );
      
      final emotes = <Emote>[];
      
      // Channel emotes
      if (channelResponse.data['channelEmotes'] != null) {
        for (final emote in channelResponse.data['channelEmotes']) {
          emotes.add(Emote(
            name: emote['code'],
            url: 'https://cdn.betterttv.net/emote/${emote['id']}/2x',
            provider: EmoteProvider.betterTTV,
          ));
        }
      }
      
      // Shared emotes
      if (channelResponse.data['sharedEmotes'] != null) {
        for (final emote in channelResponse.data['sharedEmotes']) {
          emotes.add(Emote(
            name: emote['code'],
            url: 'https://cdn.betterttv.net/emote/${emote['id']}/2x',
            provider: EmoteProvider.betterTTV,
          ));
        }
      }
      
      // Global emotes (first 50)
      final globalEmotes = globalResponse.data as List;
      for (var i = 0; i < globalEmotes.length && i < 50; i++) {
        final emote = globalEmotes[i];
        emotes.add(Emote(
          name: emote['code'],
          url: 'https://cdn.betterttv.net/emote/${emote['id']}/2x',
          provider: EmoteProvider.betterTTV,
          isGlobal: true,
        ));
      }
      
      _emoteCache[cacheKey] = emotes;
      return emotes;
    } catch (e) {
      print('Failed to load BTTV emotes: $e');
      return [];
    }
  }
  
  // ============ FFZ EMOTES ============
  
  Future<List<Emote>> getFFZEmotes(String channelId) async {
    final cacheKey = 'ffz_$channelId';
    
    if (_emoteCache.containsKey(cacheKey)) {
      return _emoteCache[cacheKey]!;
    }
    
    try {
      final response = await _dio.get(
        '${ApiConstants.ffzBaseUrl}/room/id/$channelId',
      );
      
      final emotes = <Emote>[];
      final sets = response.data['sets'];
      
      if (sets != null) {
        for (final setId in sets.keys) {
          final emotesData = sets[setId]['emoticons'];
          
          for (final emote in emotesData) {
            final urls = emote['urls'];
            final url = urls['2'] ?? urls['1'];
            
            emotes.add(Emote(
              name: emote['name'],
              url: 'https:$url',
              provider: EmoteProvider.frankerFaceZ,
            ));
          }
        }
      }
      
      _emoteCache[cacheKey] = emotes;
      return emotes;
    } catch (e) {
      print('Failed to load FFZ emotes: $e');
      return [];
    }
  }
  
  // ============ COMBINED EMOTES ============
  
  Future<Map<String, Emote>> getAllEmotes(String channelId) async {
    final allEmotes = <String, Emote>{};
    
    // Load all emote providers in parallel
    final results = await Future.wait([
      get7TVEmotes(channelId),
      getBTTVEmotes(channelId),
      getFFZEmotes(channelId),
    ]);
    
    for (final emoteList in results) {
      for (final emote in emoteList) {
        // Avoid duplicates - first provider wins
        if (!allEmotes.containsKey(emote.name)) {
          allEmotes[emote.name] = emote;
        }
      }
    }
    
    return allEmotes;
  }
  
  // Clear cache
  void clearCache() {
    _emoteCache.clear();
  }
}

// ============ EMOTE MODEL ============

class Emote {
  final String name;
  final String url;
  final EmoteProvider provider;
  final bool isZeroWidth;
  final bool isGlobal;
  
  Emote({
    required this.name,
    required this.url,
    required this.provider,
    this.isZeroWidth = false,
    this.isGlobal = false,
  });
  
  @override
  String toString() => name;
}

enum EmoteProvider {
  sevenTV,
  betterTTV,
  frankerFaceZ,
  twitch,
}
