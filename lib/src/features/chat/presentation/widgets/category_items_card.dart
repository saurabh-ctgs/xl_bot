import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/bot_response_model.dart';
import '../controllers/chat_controller.dart';
import '../theme/chat_ui_config.dart';

class CategoryItemsCard extends StatelessWidget {
  final Extra categoryData;
  final ChatController controller;
  final ChatUIConfig? uiConfig;

  const CategoryItemsCard({
    super.key,
    required this.categoryData,
    required this.controller,
    this.uiConfig,
  });

  @override
  Widget build(BuildContext context) {
    final category = categoryData.category ?? '';
    final items = List<String>.from(
      (categoryData.items as List<dynamic>?)?.map((item) => item.toString()) ?? [],
    );

    if (items.isEmpty) return const SizedBox.shrink();

    return  Align(
      alignment:  Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12,),
        child: Wrap(
          spacing: 2,
          runSpacing: -10,
          children: items.map((item) => _buildItemChip(context, item)).toList(),
        ),
      ),
    );
  }

  Widget _buildItemChip(BuildContext context, String item) {
    return Obx(() {
      final isLoading = controller.isLoadingCategory.value;

      return FilterChip(
        selected: false,
        onSelected: isLoading ? null : (_) => controller.selectCategoryItem(item),
        label: Text(item),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: -5),
      );
    });
  }
}

