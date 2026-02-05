# 🎨 Customization Guide - Xtra-Neo

Make Xtra-Neo truly yours with these customization options.

## 🌈 Themes & Colors

### Changing the Accent Color

Edit `lib/core/theme/app_theme.dart`:

```dart
// Current: Twitch Purple
static const Color twitchPurple = Color(0xFF9146FF);

// Examples:
// YouTube Red
static const Color accentColor = Color(0xFFFF0000);

// Discord Blurple  
static const Color accentColor = Color(0xFF5865F2);

// Custom Green
static const Color accentColor = Color(0xFF00FF88);
```

### Creating a Light Theme

Add to `app_theme.dart`:

```dart
static ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: twitchPurple,
    colorScheme: ColorScheme.light(
      primary: twitchPurple,
      secondary: kickGreen,
      surface: Color(0xFFF5F5F5),
      background: Colors.white,
    ),
    // ... rest of theme
  );
}
```

Then in `main.dart`:

```dart
MaterialApp(
  theme: AppTheme.lightTheme,  // or darkTheme
  // ...
)
```

### Gradient Backgrounds

Replace solid colors with gradients in `app_theme.dart`:

```dart
static BoxDecoration get gradientBackground => BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1a1a2e),
      Color(0xFF16213e),
      Color(0xFF0f3460),
    ],
  ),
);
```

## 🎮 Player Customization

### Change Buffering Settings

In `video_player_widget.dart`:

```dart
bufferingConfiguration: BetterPlayerBufferingConfiguration(
  minBufferMs: 2000,      // Lower = less lag, more rebuffering
  maxBufferMs: 10000,     // Higher = smoother but more delay
  bufferForPlaybackMs: 1000,
  bufferForPlaybackAfterRebufferMs: 2000,
)
```

**Profiles**:

**Low Latency** (for competitive games):
```dart
minBufferMs: 1000,
maxBufferMs: 5000,
```

**Stable Connection** (for movie watching):
```dart
minBufferMs: 5000,
maxBufferMs: 30000,
```

### Custom Player Controls

Create your own control layout in `video_player_widget.dart`:

```dart
class MinimalControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Only play/pause button
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
```

### Gesture Sensitivity

Adjust swipe sensitivity in `video_player_widget.dart`:

```dart
onVerticalDragUpdate: (details) {
  setState(() {
    // Higher divisor = less sensitive
    _brightness -= details.delta.dy / 500;  // Default
    _brightness -= details.delta.dy / 1000; // Less sensitive
    _brightness -= details.delta.dy / 300;  // More sensitive
  });
}
```

## 💬 Chat Customization

### Chat Message Limit

In `chat_widget.dart`:

```dart
if (_messages.length > 500) {  // Default
  _messages.removeAt(0);
}

// Options:
// 100  = Low memory, fast scrolling
// 1000 = High memory, full history
```

### Chat Font Size

```dart
Text(
  part,
  style: TextStyle(
    color: Colors.white,
    fontSize: 13,  // Default
    // fontSize: 11,  // Compact
    // fontSize: 16,  // Large
  ),
)
```

### Emote Size

```dart
CachedNetworkImage(
  imageUrl: part.url,
  height: 28,  // Default
  // height: 20,  // Small
  // height: 36,  // Large
)
```

### Chat Background Transparency

```dart
static const Color chatBackground = Color(0xE6000000);
//                                       ^^
// E6 = 90% opacity (default)
// FF = 100% opacity (fully opaque)
// CC = 80% opacity
// 80 = 50% opacity
```

## 📺 Multistream Layouts

### Add New Layout

In `multistream_grid.dart`, add to `GridLayout` enum:

```dart
enum GridLayout {
  single,
  twoVertical,
  fourGrid,
  pip,
  threeVertical,  // NEW!
}
```

Then implement the layout:

```dart
Widget _buildThreeVertical() {
  return Column(
    children: [
      Expanded(flex: 2, child: _buildStreamCard(0)),  // Main
      Expanded(flex: 1, child: _buildStreamCard(1)),  // Small
      Expanded(flex: 1, child: _buildStreamCard(2)),  // Small
    ],
  );
}
```

### Max Streams Limit

```dart
class AppConfig {
  static const int maxMultistreams = 4;  // Default
  // static const int maxMultistreams = 6;  // More streams
  // static const int maxMultistreams = 2;  // Performance mode
}
```

## 🚫 Ad-Blocking Tuning

### Aggressive Filtering

In `hls_proxy_server.dart`, add more patterns:

```dart
bool _isAdMarker(String line) {
  final adPatterns = [
    '#EXT-X-DISCONTINUITY-SEQUENCE',
    'stitched-ad',
    'amazon-ads',
    // Add your own patterns:
    'ad-break',
    'commercial',
    'sponsored',
  ];
  // ...
}
```

### Whitelist Channels (No Ad-Block)

```dart
// In twitch_datasource.dart
Future<String> getStreamUrl(String username, {bool skipProxy = false}) async {
  final whitelist = ['charity_stream', 'official_event'];
  
  if (whitelist.contains(username) || skipProxy) {
    return rawHlsUrl;  // Direct, no proxy
  }
  
  return proxiedUrl;  // Through ad-blocker
}
```

## 🎨 UI/UX Tweaks

### Button Styles

Add to `app_theme.dart`:

```dart
static ButtonStyle get roundedButton => ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),  // Pill shape
  ),
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
);
```

### Card Styles

```dart
static BoxDecoration get neuomorphicCard => BoxDecoration(
  color: cardGrey,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      offset: Offset(5, 5),
      blurRadius: 10,
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.05),
      offset: Offset(-5, -5),
      blurRadius: 10,
    ),
  ],
);
```

### Animations

Enable hero animations between pages:

```dart
// In browse_page.dart
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StreamPlayerPage(
          tag: 'stream_${stream.id}',
        ),
      ),
    );
  },
  child: Hero(
    tag: 'stream_${stream.id}',
    child: StreamThumbnail(),
  ),
)
```

## 🔧 Performance Modes

### Battery Saver Mode

Add to settings:

```dart
class PerformanceMode {
  static bool batterySaver = false;
  
  static BetterPlayerConfiguration getConfig() {
    if (batterySaver) {
      return BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: false,  // Manual start
        // Lower quality, less buffer
      );
    }
    return normalConfig;
  }
}
```

### Data Saver Mode

Automatically use lower quality:

```dart
Future<String> getStreamUrl(String username, {String? quality}) async {
  final dataSaver = await SharedPreferences.getInstance()
      .then((prefs) => prefs.getBool('data_saver') ?? false);
  
  if (dataSaver) {
    quality = '480p';  // Force lower quality
  }
  
  // ... rest of method
}
```

## 🌍 Localization

### Add Language Support

1. Create `lib/l10n/app_en.arb`:

```json
{
  "@@locale": "en",
  "appTitle": "Xtra-Neo",
  "browse": "Browse",
  "following": "Following",
  "multistream": "Multistream",
  "settings": "Settings"
}
```

2. Add to `pubspec.yaml`:

```yaml
flutter:
  generate: true
```

3. Use in code:

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Text(AppLocalizations.of(context)!.browse)
```

## 🎯 Custom Features

### Picture-in-Picture

Enable system PiP (Android 8+):

```dart
// Add to AndroidManifest.xml
<activity
  android:supportsPictureInPicture="true"
  android:configChanges="screenSize|smallestScreenSize|screenLayout|orientation"
/>

// In Dart
import 'package:pip_view/pip_view.dart';

PIPView(
  builder: (context, isFloating) {
    return VideoPlayerWidget();
  },
)
```

### Stream Notifications

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> checkLiveStatus(String channelId) async {
  final isLive = await twitchDataSource.getStream(channelId);
  
  if (isLive != null) {
    final notifications = FlutterLocalNotificationsPlugin();
    notifications.show(
      channelId.hashCode,
      'Channel is live!',
      '${isLive['user_name']} started streaming',
      NotificationDetails(/* ... */),
    );
  }
}
```

## 🔐 Privacy Options

### Disable Emote CDN

```dart
// In emotes_datasource.dart
class EmotesDataSource {
  static bool enableEmotes = true;  // Make configurable
  
  Future<Map<String, Emote>> getAllEmotes(String channelId) async {
    if (!enableEmotes) {
      return {};  // No emotes loaded
    }
    // ... rest
  }
}
```

### Clear Cache on Exit

```dart
@override
void dispose() {
  if (clearCacheOnExit) {
    CachedNetworkImageProvider.evictFromCache();
    _emotesDataSource.clearCache();
  }
  super.dispose();
}
```

## 📱 Platform-Specific

### iOS Support (Future)

Modify for iOS in `main.dart`:

```dart
if (Platform.isIOS) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light,
  );
} else {
  // Android config
}
```

### Tablet Layout

Detect and use tablet UI:

```dart
bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.shortestSide >= 600;
}

@override
Widget build(BuildContext context) {
  if (isTablet(context)) {
    return TabletLayout();
  }
  return MobileLayout();
}
```

---

## 🚀 Applying Changes

After making customizations:

```bash
# Hot reload (Dart changes only)
flutter run
# Press 'r' in terminal

# Hot restart (UI changes)
# Press 'R' in terminal

# Full rebuild (native changes)
flutter clean
flutter run
```

## 💡 Tips

- **Test on real device**: Emulator doesn't handle video well
- **Backup before customizing**: `git commit -m "backup"`
- **Start small**: Change one thing at a time
- **Check logs**: `flutter run --verbose`

---

**Need help?** Open an issue on GitHub with `[Customization]` tag!
