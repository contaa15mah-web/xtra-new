// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // AMOLED Dark Colors
  static const Color amoledBlack = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF121212);
  static const Color cardGrey = Color(0xFF1E1E1E);
  static const Color twitchPurple = Color(0xFF9146FF);
  static const Color kickGreen = Color(0xFF53FC18);
  static const Color accentRed = Color(0xFFFF4444);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: amoledBlack,
      primaryColor: twitchPurple,
      colorScheme: const ColorScheme.dark(
        primary: twitchPurple,
        secondary: kickGreen,
        surface: cardGrey,
        background: amoledBlack,
        error: accentRed,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: amoledBlack,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: cardGrey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: twitchPurple,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Text
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        labelLarge: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      
      // Icons
      iconTheme: const IconThemeData(color: textPrimary),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkGrey,
        selectedItemColor: twitchPurple,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
  
  // Player Overlay Colors
  static const Color playerOverlay = Color(0xAA000000);
  static const Color playerControlActive = twitchPurple;
  static const Color playerControlInactive = Color(0x88FFFFFF);
  
  // Chat Colors
  static const Color chatBackground = Color(0xE6000000);
  static const Color chatMessage = Color(0xFF1E1E1E);
  static const Color chatUsername = twitchPurple;
  
  // Status Colors
  static const Color liveIndicator = accentRed;
  static const Color offlineIndicator = Color(0xFF666666);
}

// Custom Widgets Styles
class AppStyles {
  static BoxDecoration get glassmorphism => BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
  );
  
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
}
