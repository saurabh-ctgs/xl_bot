import 'package:flutter/material.dart';

/// Chat theme configuration for dynamic styling
class ChatTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color userMessageColor;
  final Color botMessageColor;
  final Color userTextColor;
  final Color botTextColor;
  final bool isDark;

  const ChatTheme({
    this.primaryColor = const Color(0xFF6366F1),
    this.secondaryColor = const Color(0xFF8B5CF6),
    this.backgroundColor = Colors.white,
    this.userMessageColor = const Color(0xFF6366F1),
    this.botMessageColor = const Color(0xFFF3F4F6),
    this.userTextColor = Colors.white,
    this.botTextColor = Colors.black87,
    this.isDark = false,
  });

  /// Create a dark theme variant
  factory ChatTheme.dark({
    Color primaryColor = const Color(0xFF6366F1),
    Color secondaryColor = const Color(0xFF8B5CF6),
  }) {
    return ChatTheme(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      backgroundColor: const Color(0xFF1F2937),
      userMessageColor: primaryColor,
      botMessageColor: const Color(0xFF374151),
      userTextColor: Colors.white,
      botTextColor: Colors.white,
      isDark: true,
    );
  }

  /// Create a light theme variant
  factory ChatTheme.light({
    Color primaryColor = const Color(0xFF6366F1),
    Color secondaryColor = const Color(0xFF8B5CF6),
  }) {
    return ChatTheme(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      backgroundColor: Colors.white,
      userMessageColor: primaryColor,
      botMessageColor: const Color(0xFFF3F4F6),
      userTextColor: Colors.white,
      botTextColor: Colors.black87,
      isDark: false,
    );
  }

  /// Create a custom theme
  factory ChatTheme.custom({
    required Color primaryColor,
    required Color secondaryColor,
    Color? backgroundColor,
    Color? userMessageColor,
    Color? botMessageColor,
    Color? userTextColor,
    Color? botTextColor,
  }) {
    return ChatTheme(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      backgroundColor: backgroundColor ?? Colors.white,
      userMessageColor: userMessageColor ?? primaryColor,
      botMessageColor: botMessageColor ?? const Color(0xFFF3F4F6),
      userTextColor: userTextColor ?? Colors.white,
      botTextColor: botTextColor ?? Colors.black87,
      isDark: backgroundColor == null ? false : backgroundColor.computeLuminance() < 0.5,
    );
  }
}

