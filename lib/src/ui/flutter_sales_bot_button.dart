// lib/src/widgets/salesbot_button.dart
import 'package:flutter/material.dart';
import '../config.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/chat/presentation/theme/chat_ui_config.dart';
import '../features/chat/presentation/theme/chat_ui_config_manager.dart';
import '../model/action_button.dart';

class SalesBotButton extends StatelessWidget {
  final SalesBotConfig? config;
  final ChatUIConfig? uiConfig;
  final Function(dynamic value)? onTap;
  final List<ActionButton>? actionButtons;

  // Button customization
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? size;
  final String? heroTag;
  final String? tooltip;
  final ShapeBorder? shape;
  final double? elevation;
  final bool useGradient;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onPressed;


  const SalesBotButton({
    super.key,
    this.config,
    this.uiConfig,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.size,
    this.heroTag,
    this.tooltip,
    this.shape,
    this.elevation,
    this.useGradient = true,
    this.margin,
    this.onPressed,
    this.onTap,
    this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    // Get UI config
    final chatConfig = uiConfig ?? ChatUIConfigManager.instance.config;

    // Determine colors
    final bgColor = backgroundColor ?? chatConfig.primaryColor;
    final fgColor = foregroundColor ?? Colors.white;
    final buttonSize = size ?? 56.0;

    // Custom onPressed or default navigation
    final pressHandler = onPressed ?? () => _navigateToChat(context);

    // Build gradient FAB if enabled
    if (useGradient) {
      return Container(
        margin: margin,
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              chatConfig.primaryColor,
              chatConfig.secondaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(buttonSize / 2),
          boxShadow: [
            BoxShadow(
              color: chatConfig.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: pressHandler,
            borderRadius: BorderRadius.circular(buttonSize / 2),
            child: Center(
              child: icon ?? Icon(
                Icons.chat_bubble_rounded,
                color: fgColor,
                size: buttonSize * 0.5,
              ),
            ),
          ),
        ),
      );
    }

    // Standard FAB
    return Container(
      margin: margin,
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: pressHandler,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: elevation,
        tooltip: tooltip ?? 'Open Chat',
        shape: shape,
        child: icon ?? const Icon(Icons.chat_bubble_rounded),
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(uiConfig: uiConfig,actionButtons: actionButtons,),
      ),
    );
  }
}

/// Extended version with more customization options
class SalesBotFloatingButton extends StatelessWidget {
  final SalesBotConfig? config;
  final ChatUIConfig? uiConfig;

  // Position
  final Alignment alignment;
  final EdgeInsetsGeometry? margin;

  // Appearance
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final bool useGradient;
  final bool showLabel;
  final String? label;
  final double? elevation;

  // Behavior
  final VoidCallback? onPressed;
  final bool animated;
  final Duration animationDuration;

  const SalesBotFloatingButton({
    super.key,
    this.config,
    this.uiConfig,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(16),
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 56.0,
    this.useGradient = true,
    this.showLabel = false,
    this.label,
    this.elevation,
    this.onPressed,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final chatConfig = uiConfig ?? ChatUIConfigManager.instance.config;

    Widget button = _buildButton(context, chatConfig);

    // Wrap with animation if enabled
    if (animated) {
      button = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: animationDuration,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: button,
      );
    }

    return Align(
      alignment: alignment,
      child: Container(
        margin: margin,
        child: button,
      ),
    );
  }

  Widget _buildButton(BuildContext context, ChatUIConfig chatConfig) {
    final bgColor = backgroundColor ?? chatConfig.primaryColor;
    final fgColor = foregroundColor ?? Colors.white;

    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon ?? Icon(
          Icons.chat_bubble_rounded,
          color: fgColor,
          size: size * 0.45,
        ),
        if (showLabel && label != null) ...[
          const SizedBox(width: 8),
          Text(
            label!,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );

    if (useGradient) {
      return Container(
        height: size,
        padding: showLabel
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
            : null,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [chatConfig.primaryColor, chatConfig.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: chatConfig.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed ,
            borderRadius: BorderRadius.circular(size / 2),
            child: Container(
              width: showLabel ? null : size,
              height: size,
              alignment: Alignment.center,
              child: buttonContent,
            ),
          ),
        ),
      );
    }

    if (showLabel && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: elevation,
        icon: icon ?? const Icon(Icons.chat_bubble_rounded),
        label: Text(label!),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed ,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation,
      child: icon ?? const Icon(Icons.chat_bubble_rounded),
    );
  }


}

/// Compact mini button version
class SalesBotMiniButton extends StatelessWidget {
  final SalesBotConfig? config;
  final ChatUIConfig? uiConfig;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;

  const SalesBotMiniButton({
    super.key,
    this.config,
    this.uiConfig,
    this.onPressed,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final chatConfig = uiConfig ?? ChatUIConfigManager.instance.config;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: FloatingActionButton.small(
        onPressed: onPressed ?? () => _navigateToChat(context),
        backgroundColor: chatConfig.primaryColor,
        child: const Icon(Icons.chat, size: 20),
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(uiConfig: uiConfig),
      ),
    );
  }
}