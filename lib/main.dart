// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xtra_neo/core/theme/app_theme.dart';
import 'package:xtra_neo/core/utils/hls_proxy_server.dart';
import 'package:xtra_neo/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.amoledBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Lock orientation to portrait (can be changed)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Start HLS proxy server for ad-blocking
  try {
    await hlsProxyServer.start();
  } catch (e) {
    print('Warning: Failed to start HLS proxy server: $e');
  }
  
  runApp(const XtraNeoApp());
}

class XtraNeoApp extends StatelessWidget {
  const XtraNeoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xtra-Neo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
