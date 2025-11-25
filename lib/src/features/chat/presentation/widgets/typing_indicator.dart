// lib/features/chat/presentation/widgets/typing_indicator.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/chat_ui_config.dart';

class TypingIndicator extends StatelessWidget {
  final ChatUIConfig? uiConfig;

  const TypingIndicator({super.key, this.uiConfig});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(context, 0),
            const SizedBox(width: 4),
            _buildDot(context, 1),
            const SizedBox(width: 4),
            _buildDot(context, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
    )
        .animate(
      onPlay: (controller) => controller.repeat(),
    )
        .fadeIn(delay: Duration(milliseconds: 200 * index))
        .fadeOut(
      delay: Duration(milliseconds: 400 + 200 * index),
    );
  }
}
