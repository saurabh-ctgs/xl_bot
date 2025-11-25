import 'package:flutter/material.dart';
import 'chat_ui_config.dart';

/// Singleton manager for ChatUIConfig
class ChatUIConfigManager {
  static final ChatUIConfigManager _instance = ChatUIConfigManager._internal();

  factory ChatUIConfigManager() => _instance;

  ChatUIConfigManager._internal();

  static ChatUIConfigManager get instance => _instance;

  ChatUIConfig? _config;

  /// Get current configuration or default light theme
  ChatUIConfig get config => _config ?? ChatUIConfig.light();

  /// Check if config is initialized
  bool get isInitialized => _config != null;

  /// Initialize with a specific configuration
  void initialize(ChatUIConfig config) {
    _config = config;
  }

  /// Initialize with light theme
  void initializeLight() {
    _config = ChatUIConfig.light();
  }

  /// Initialize with dark theme
  void initializeDark() {
    _config = ChatUIConfig.dark();
  }

  /// Initialize with custom colors
  void initializeCustom({
    required Color primaryColor,
    required Color secondaryColor,
    bool isDark = false,
  }) {
    _config = ChatUIConfig.custom(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      isDark: isDark,
    );
  }

  /// Initialize based on system brightness
  void initializeFromBrightness(Brightness brightness) {
    _config = brightness == Brightness.dark
        ? ChatUIConfig.dark()
        : ChatUIConfig.light();
  }

  /// Update configuration
  void updateConfig(ChatUIConfig config) {
    _config = config;
  }

  /// Reset to default
  void reset() {
    _config = null;
  }
}