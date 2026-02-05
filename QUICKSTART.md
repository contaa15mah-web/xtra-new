# ⚡ Quick Start Guide - Xtra-Neo

Get up and running in 5 minutes!

## 🎯 Prerequisites

- Flutter SDK 3.19.0+ ([Install](https://docs.flutter.dev/get-started/install))
- Java 17+ ([Install](https://adoptium.net/))
- Android Studio or VS Code
- Android device or emulator

## 🚀 Installation

### 1. Clone & Setup

```bash
cd xtra_neo
chmod +x setup.sh
./setup.sh
```

The setup script will:
- ✅ Check Flutter & Java
- ✅ Install dependencies  
- ✅ Run code generation
- ✅ Create required directories

### 2. Configure Twitch API (Required for Twitch features)

1. Go to https://dev.twitch.tv/console/apps
2. Click "Register Your Application"
3. Fill in:
   - Name: `Xtra-Neo`
   - OAuth Redirect URL: `xtraneo://oauth`
   - Category: `Application Integration`
4. Copy **Client ID** and **Client Secret**
5. Edit `lib/core/constants/api_constants.dart`:

```dart
static const String twitchClientId = 'YOUR_CLIENT_ID_HERE';
static const String twitchClientSecret = 'YOUR_SECRET_HERE';
```

### 3. Run the App

```bash
# Debug mode (hot reload enabled)
flutter run

# Release mode (optimized)
flutter run --release
```

## 📦 Building APK

### Quick Build (All architectures)

```bash
flutter build apk --release --split-per-abi
```

Outputs in `build/app/outputs/flutter-apk/`:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM) ⭐ Most common
- `app-x86_64-release.apk` (Emulator)

### Optimized Build (Smaller APK)

```bash
# ARM64 only (95% of modern devices)
flutter build apk --release --target-platform android-arm64

# With obfuscation (harder to reverse engineer)
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

## 🎮 First Use

### Browse Streams

1. Open app → **Browse** tab
2. Switch between **Twitch** / **Kick** tabs
3. Tap any stream to watch

### Multistream Setup

1. Go to **Multistream** tab
2. Tap **+** button
3. Select platform (Twitch/Kick)
4. Enter username (e.g., `shroud`, `xqc`)
5. Tap **Add**
6. Repeat for more streams
7. Change layout with grid icon

### Chat Features

- Emotes load automatically (7TV, BTTV, FFZ)
- Tap chat to expand/collapse
- Long press emotes for details
- Toggle auto-scroll with arrow button

## ⚙️ Settings

Navigate to **Settings** tab to configure:

- **Ad-Block**: Enable/disable HLS proxy (on by default)
- **Video Quality**: Auto, 1080p60, 720p60, 480p, 360p, Audio Only
- **Emotes**: Toggle 7TV, BTTV, FFZ
- **Theme**: Dark, AMOLED, Custom

## 🐛 Troubleshooting

### "Proxy server failed to start"

- Check if port 8080 is available
- Try restarting the app
- Disable firewall/VPN

### "Stream won't load"

- Check internet connection
- Verify channel is live
- Try different quality setting
- Check Twitch API keys (if Twitch stream)

### "Emotes not showing"

- Wait a few seconds (loading from CDN)
- Check internet connection
- Clear app cache

### "Build failed"

```bash
# Clean build
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

## 📝 Development

### Hot Reload

```bash
# Run in debug mode
flutter run

# In terminal, press:
# r = hot reload
# R = hot restart
# q = quit
```

### Debugging

```bash
# Enable verbose logging
flutter run --verbose

# Open DevTools
flutter run
# Then press 'D' in terminal
```

### VSCode Setup

1. Install extensions:
   - Flutter
   - Dart
   - Error Lens

2. Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Xtra-Neo",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart"
    }
  ]
}
```

## 🎯 Next Steps

- [ ] Login with Twitch account
- [ ] Follow your favorite channels  
- [ ] Create multistream layouts
- [ ] Customize chat settings
- [ ] Export settings backup

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/xtra-neo/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/xtra-neo/discussions)
- **Email**: support@xtraneo.app (if available)

## 📚 Learn More

- [Full Documentation](README.md)
- [Development Guide](DEVELOPMENT.md)
- [Flutter Docs](https://docs.flutter.dev)
- [Twitch API Docs](https://dev.twitch.tv/docs)

---

**Enjoy streaming!** 🎮✨
