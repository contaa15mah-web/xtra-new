# 🚀 Xtra-Neo

Advanced multistream player for Twitch and Kick with native ad-blocking, built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-3.19.0-blue)
![License](https://img.shields.io/badge/License-GPL--3.0-green)

## ✨ Features

### 🎮 Dual Platform Support
- **Twitch**: Full OAuth2 authentication, live streams, VODs
- **Kick**: Stream support with WebSocket chat integration

### 🚫 Ad-Block Nativo
- Local HLS proxy server
- Automatic ad segment filtering
- No external proxies needed
- Works on both Twitch and Kick

### 📺 Multistream
- **Grid Layouts**: 1x1, 2x1, 1x2, 2x2
- **Picture-in-Picture**: Watch multiple streams simultaneously
- **Independent Controls**: Mute, audio-only mode per stream
- **Dynamic Layout Switching**: Change layouts on the fly

### 💬 Advanced Chat
- Full emote support:
  - 7TV
  - BetterTTV (BTTV)
  - FrankerFaceZ (FFZ)
- Chat badges
- Timestamps
- Auto-scroll with manual override
- Emote picker

### 🎨 Beautiful UI
- AMOLED Dark Mode
- Gesture controls (brightness/volume)
- Smooth animations
- Material Design 3

## 🛠️ Tech Stack

- **Framework**: Flutter 3.19.0
- **Video Engine**: Better Player (HLS support)
- **State Management**: BLoC Pattern
- **Networking**: Dio + WebSocket
- **Storage**: Hive + SharedPreferences
- **Build**: GitHub Actions

## 📦 Installation

### Prerequisites

```bash
# Install Flutter 3.19.0 or higher
flutter --version

# Install dependencies
flutter pub get
```

### Configuration

1. **Twitch API Keys**

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String twitchClientId = 'YOUR_CLIENT_ID_HERE';
static const String twitchClientSecret = 'YOUR_CLIENT_SECRET_HERE';
```

Get your keys from: https://dev.twitch.tv/console

2. **Build Runner**

Generate required files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🔨 Building

### Debug Build

```bash
flutter run
```

### Release APK

```bash
# Build for all architectures
flutter build apk --release --split-per-abi

# APKs will be in:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### GitHub Actions

The project includes automated builds via GitHub Actions:

1. Push to `main` or `develop` branch
2. GitHub Actions automatically builds APK
3. Download from Actions artifacts
4. For releases, tag with `v1.0.0` format

## 📁 Project Structure

```
xtra_neo/
├── lib/
│   ├── core/
│   │   ├── constants/          # API URLs, keys
│   │   ├── theme/              # AMOLED dark theme
│   │   └── utils/              # HLS proxy server
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── twitch/         # Twitch API integration
│   │   │   ├── kick/           # Kick.com scraping
│   │   │   └── emotes/         # 7TV, BTTV, FFZ
│   │   ├── models/
│   │   └── repositories/
│   ├── presentation/
│   │   ├── pages/              # App screens
│   │   └── widgets/            # Reusable components
│   │       ├── video_player_widget.dart
│   │       ├── multistream_grid.dart
│   │       └── chat_widget.dart
│   └── main.dart
├── android/                    # Android configuration
├── .github/workflows/          # CI/CD
└── pubspec.yaml
```

## 🔧 Key Components

### HLS Proxy Server

The ad-blocking magic happens in `lib/core/utils/hls_proxy_server.dart`:

- Runs local Shelf server on port 8080
- Intercepts M3U8 playlists
- Filters ad segments
- Rewrites URLs transparently

### Multistream Grid

`lib/presentation/widgets/multistream_grid.dart`:

- Supports up to 4 concurrent streams
- Dynamic layout switching
- Independent audio controls
- Picture-in-Picture mode

### Emotes System

`lib/data/datasources/emotes/emotes_datasource.dart`:

- Fetches emotes from 3 providers
- Caches for performance
- Replaces text with images in chat

## 🎯 Usage

### Adding Streams

1. Navigate to **Multistream** tab
2. Tap the **+** button
3. Select platform (Twitch/Kick)
4. Enter channel username
5. Stream loads automatically

### Chat Features

- Tap message area to show/hide chat
- Long press on emotes to see details
- Toggle auto-scroll with arrow button
- Access emote picker with smile icon

### Video Controls

- **Swipe left side**: Adjust brightness
- **Swipe right side**: Adjust volume
- **Tap**: Show/hide controls
- **Audio-only**: Toggle per stream to save data

## 🐛 Known Issues

- HLS proxy may not work on some networks (firewall)
- Kick chat requires WebSocket support
- Some emotes may fail to load (rate limiting)

## 🔐 Privacy

- No data collection
- All API calls direct to platforms
- Local-only storage
- No analytics

## 📜 License

GPL-3.0 License - Based on [Xtra](https://github.com/crackededed/Xtra)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open Pull Request

## 🙏 Credits

- Based on [Xtra](https://github.com/crackededed/Xtra)
- Better Player for HLS support
- Twitch API
- Kick.com unofficial API
- 7TV, BetterTTV, FrankerFaceZ

## 📞 Support

- Issues: https://github.com/yourusername/xtra-neo/issues
- Discord: [Coming Soon]

---

**Disclaimer**: This is an unofficial app. Not affiliated with Twitch, Kick, or Amazon.
