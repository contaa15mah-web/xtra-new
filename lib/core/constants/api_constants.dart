// lib/core/constants/api_constants.dart

class ApiConstants {
  // Twitch API
  static const String twitchClientId = 'YOUR_TWITCH_CLIENT_ID';
  static const String twitchClientSecret = 'YOUR_TWITCH_CLIENT_SECRET';
  static const String twitchRedirectUri = 'xtraneo://oauth';
  
  static const String twitchBaseUrl = 'https://api.twitch.tv/helix';
  static const String twitchAuthUrl = 'https://id.twitch.tv/oauth2';
  static const String twitchUsherUrl = 'https://usher.ttvnw.net';
  static const String twitchGqlUrl = 'https://gql.twitch.tv/gql';
  
  // Kick API (Unofficial)
  static const String kickBaseUrl = 'https://kick.com/api/v2';
  static const String kickStreamUrl = 'https://kick.com/api/v2/channels';
  static const String kickChatUrl = 'wss://ws-us2.pusher.com/app/eb1d5f283081a78b932c';
  
  // Emotes APIs
  static const String seventvBaseUrl = 'https://7tv.io/v3';
  static const String bttvBaseUrl = 'https://api.betterttv.net/3';
  static const String ffzBaseUrl = 'https://api.frankerfacez.com/v1';
  
  // HLS Proxy (Local - Ad-block)
  static const String proxyPort = '8080';
  static const String proxyBaseUrl = 'http://localhost:8080';
  
  // Headers
  static Map<String, String> get twitchHeaders => {
    'Client-ID': twitchClientId,
    'Accept': 'application/vnd.twitchtv.v5+json',
  };
  
  static Map<String, String> get kickHeaders => {
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36',
  };
}

class StorageKeys {
  static const String twitchAccessToken = 'twitch_access_token';
  static const String twitchRefreshToken = 'twitch_refresh_token';
  static const String userId = 'user_id';
  static const String username = 'username';
  static const String favoriteChannels = 'favorite_channels';
  static const String chatSettings = 'chat_settings';
  static const String videoQuality = 'video_quality';
  static const String audioOnly = 'audio_only';
}

class AppConfig {
  static const String appName = 'Xtra-Neo';
  static const String version = '1.0.0';
  static const int maxMultistreams = 4;
  static const int chatMessageLimit = 500;
  static const Duration tokenRefreshThreshold = Duration(hours: 1);
}
