// lib/features/chat/presentation/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_sales_bot/src/features/chat/presentation/controllers/chat_controller.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/message_entity.dart';
import '../theme/chat_ui_config.dart';
import '../theme/chat_ui_config_manager.dart';
import 'category_items_card.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final ChatController chatController;
  final ChatUIConfig? uiConfig;

  const MessageBubble({
    super.key,
    required this.message,
    this.uiConfig, required this.chatController,
  });

  @override
  Widget build(BuildContext context) {
    final config = uiConfig ?? ChatUIConfigManager.instance.config;
    final isUser = message.type == MessageType.user;

    // If a custom builder is provided, use it (consumer responsible for layout)
    if (config.messageBubbleBuilder != null) {
      return config.messageBubbleBuilder!(context, message, chatController, config);
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: config.messageMargin,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * config.messageBubbleMaxWidth,
        ),
        child: Column(
          crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: config.messagePadding + 4,
                vertical: config.messagePadding,
              ),
              decoration: BoxDecoration(
                gradient: isUser && config.useGradientForUserMessages
                    ? config.userMessageGradient
                    : null,
                color: isUser && !config.useGradientForUserMessages
                    ? config.userMessageColor
                    : !isUser
                    ? config.botMessageColor
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(config.messageBorderRadius),
                  topRight: Radius.circular(config.messageBorderRadius),
                  bottomLeft: Radius.circular(
                    isUser ? config.messageBorderRadius : 4,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? 4 : config.messageBorderRadius,
                  ),
                ),
                boxShadow: config.messageShadow,
              ),
              child: Text(
                message.content,
                style: config.messageTextStyle ??
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUser ? config.userTextColor : config.botTextColor,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            if (message.categoryData != null) ...[
              CategoryItemsCard(
                categoryData: message.categoryData!,
                controller:chatController,
                uiConfig: uiConfig,
              )
                  .animate()
                  .fadeIn(duration: uiConfig?.slideInDuration, delay: 200.ms)
                  .slideX(begin: 0.2, end: 0),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: config.timestampStyle ??
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}