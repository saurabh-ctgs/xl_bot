// dart
// File: `lib/src/features/chat/presentation/widgets/service_card.dart`
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../model/action_button.dart';
import '../../data/models/service_model.dart';
import '../theme/chat_ui_config.dart';

class ServiceCard extends StatelessWidget {
  final ProductItemModel service;
  final ChatUIConfig? uiConfig;
  final List<ActionButton>? actionButtons ;

  const ServiceCard({super.key, required this.service, this.uiConfig,  this.actionButtons});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(context),
          _buildContent(context),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl:  service.thumbnails!.isNotEmpty ? service.thumbnails!.first : '',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 180,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 180,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image_not_supported, size: 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.title ?? 'Service',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            service.description ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }


  Widget _buildActions(BuildContext context) {
    final buttons = actionButtons;
    return Padding(
      padding: const EdgeInsets.all(16).copyWith(top: 0),
      child: buttons != null && buttons.isNotEmpty
          ? Row(
              children: buttons.asMap().entries.map((entry) {
                final btn = entry.value;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: ()=>btn.onTap(service,),
                      child: btn.widget,
                    )
                  ),
                );
              }).toList(),
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => uiConfig?.onTapDefaultActionButton?.call(service),
                style: ElevatedButton.styleFrom(
                  backgroundColor: uiConfig?.primaryColor ?? Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
    );
  }
}