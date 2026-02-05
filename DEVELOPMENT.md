# 🔬 Development Guide - Xtra-Neo

## Advanced Configuration & Troubleshooting

### 🔑 OAuth Setup (Detailed)

#### Creating Twitch Application

1. Go to https://dev.twitch.tv/console/apps
2. Click "Register Your Application"
3. Fill in:
   - **Name**: Xtra-Neo
   - **OAuth Redirect URLs**: `xtraneo://oauth`
   - **Category**: Application Integration
4. Click "Create"
5. Copy **Client ID** and generate **Client Secret**
6. Add to `lib/core/constants/api_constants.dart`

#### Testing OAuth Flow

```bash
# Run app and trigger login
flutter run

# Monitor OAuth callback
adb logcat | grep "OAuth"
```

### 🚫 Ad-Blocking Deep Dive

#### How It Works

The HLS proxy intercepts `.m3u8` playlists and filters segments:

1. **Request Flow**:
   ```
   App → Local Proxy (8080) → Twitch Servers
   ```

2. **Playlist Parsing**:
   - Master playlist → Quality variants
   - Media playlist → Video segments (.ts files)
   
3. **Ad Detection**:
   ```dart
   // Patterns we look for:
   - #EXT-X-DISCONTINUITY-SEQUENCE
   - CLASS="stitched-ad"
   - amazon-ads markers
   ```

4. **Segment Filtering**:
   - Keep: Regular video segments
   - Remove: Ad segments + markers

#### Debugging Proxy

```dart
// Enable verbose logging in hls_proxy_server.dart
print('Playlist before filtering:\n$playlist');
print('Playlist after filtering:\n$filteredPlaylist');
```

Test with curl:
```bash
curl "http://localhost:8080/proxy?url=https://usher.ttvnw.net/..."
```

### 📺 Multistream Architecture

#### Layout Management

```dart
enum GridLayout {
  single,      // 1 stream, fullscreen
  twoVertical, // 2 streams, stacked
  fourGrid,    // 4 streams, 2x2
  pip,         // 1 main + 1 floating
}
```

#### Performance Optimization

**Problem**: Multiple video decoders drain battery

**Solutions Implemented**:

1. **Audio-Only Mode**:
   ```dart
   // Black overlay, audio plays
   if (widget.audioOnly) {
     return ColoredBox(color: Colors.black);
   }
   ```

2. **Lazy Loading**:
   ```dart
   // Only initialize visible streams
   if (index >= _streams.length) {
     return Placeholder();
   }
   ```

3. **Buffering Config**:
   ```dart
   bufferingConfiguration: BetterPlayerBufferingConfiguration(
     minBufferMs: 2000,  // Low latency
     maxBufferMs: 10000, // Prevent OOM
   )
   ```

### 💬 Chat System Details

#### Emote Loading Pipeline

1. **Fetch** from APIs:
   ```dart
   Future.wait([
     get7TVEmotes(channelId),
     getBTTVEmotes(channelId),
     getFFZEmotes(channelId),
   ])
   ```

2. **Cache** in memory:
   ```dart
   Map<String, Emote> _emoteCache = {};
   ```

3. **Parse** messages:
   ```dart
   "Hello Kappa 123" → ["Hello ", <Emote>, " 123"]
   ```

4. **Render** with CachedNetworkImage

#### WebSocket for Kick Chat

```dart
// Pusher protocol
final wsUrl = 'wss://ws-us2.pusher.com/app/...';
channel.sink.add(jsonEncode({
  'event': 'pusher:subscribe',
  'data': {'channel': 'chatrooms.$id.v2'},
}));
```

#### Twitch IRC (Future Enhancement)

```dart
// Not yet implemented - would use IRC WebSocket
ws://irc-ws.chat.twitch.tv:80
// Commands: JOIN #channel, PRIVMSG, etc.
```

### 🎨 UI Customization

#### Theme Variants

Add in `app_theme.dart`:

```dart
static ThemeData get oledTheme {
  return darkTheme.copyWith(
    scaffoldBackgroundColor: Color(0xFF000000),
    // Pure black for OLED burn-in protection
  );
}

static ThemeData get gruvboxTheme {
  return darkTheme.copyWith(
    primaryColor: Color(0xFFfb4934),
    // Gruvbox color palette
  );
}
```

#### Custom Player Skins

```dart
// In video_player_widget.dart
class MinimalPlayerControls extends CustomPlayerControls {
  // Only play/pause, no other buttons
}
```

### 🔍 Debugging Tools

#### Network Inspector

```bash
# Monitor all HTTP/WebSocket traffic
flutter run --observatory-port=8888
# Open DevTools → Network tab
```

#### Video Debugging

```dart
// Log all player events
eventListener: (event) {
  print('Player Event: ${event.betterPlayerEventType}');
  print('Duration: ${event.duration}');
  print('Position: ${event.position}');
}
```

#### Chat Message Logging

```dart
widget.messageStream.listen((message) {
  print('[$message.timestamp] ${message.username}: ${message.message}');
});
```

### ⚡ Performance Tips

#### Reduce APK Size

1. **Remove unused resources**:
   ```bash
   flutter build apk --release --target-platform android-arm64
   # Single architecture = smaller APK
   ```

2. **Obfuscate code**:
   ```bash
   flutter build apk --obfuscate --split-debug-info=./debug-info
   ```

3. **Compress assets**:
   ```bash
   # Use webp instead of png for images
   cwebp input.png -o output.webp
   ```

#### Battery Optimization

- Use `audioOnly` mode when screen is off
- Reduce buffer size for live streams
- Implement picture-in-picture (Android 8+)

#### Memory Management

```dart
@override
void dispose() {
  _betterPlayerController?.dispose();
  _emotesDataSource.clearCache();
  _chatChannel?.sink.close();
  super.dispose();
}
```

### 🧪 Testing

#### Unit Tests

```dart
// test/datasources/twitch_datasource_test.dart
test('Should fetch stream URL', () async {
  final dataSource = TwitchDataSource();
  final url = await dataSource.getStreamUrl('shroud');
  expect(url, contains('.m3u8'));
});
```

#### Widget Tests

```dart
testWidgets('Multistream grid shows streams', (tester) async {
  await tester.pumpWidget(MultiStreamGrid());
  expect(find.byType(VideoPlayerWidget), findsWidgets);
});
```

#### Integration Tests

```bash
# Run on real device
flutter drive --target=test_driver/app.dart
```

### 🚀 Release Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Test on multiple devices (ARM, x86)
- [ ] Verify ad-blocking works
- [ ] Check OAuth flow
- [ ] Test multistream layouts
- [ ] Verify emotes load
- [ ] Run `flutter analyze`
- [ ] Build signed APK
- [ ] Upload to GitHub Releases

### 🔮 Future Features

#### Planned Enhancements

1. **VOD Support**:
   - Browse past broadcasts
   - Seek timeline
   - Clip creation

2. **Enhanced Chat**:
   - Send messages (requires auth)
   - @ mentions
   - Reply threads
   - Chat filters

3. **Additional Platforms**:
   - YouTube Live
   - Trovo
   - Facebook Gaming

4. **Desktop Support**:
   - Windows/macOS builds
   - Keyboard shortcuts
   - Multi-monitor support

### 📚 Resources

- [Better Player Docs](https://pub.dev/packages/better_player)
- [Twitch API Reference](https://dev.twitch.tv/docs/api)
- [Kick.com Unofficial Docs](https://github.com/kick-api/kick-api)
- [HLS Specification](https://datatracker.ietf.org/doc/html/rfc8216)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)

### 🤝 Getting Help

- **Stack Overflow**: Tag `flutter` + `twitch`
- **Discord**: Flutter community
- **GitHub Issues**: Bug reports

---

**Pro Tip**: Always test on a real device. The Android emulator doesn't handle video playback well!
