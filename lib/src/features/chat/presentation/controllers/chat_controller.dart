import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatController extends GetxController {
  final SendMessageUseCase sendMessageUseCase;
  final ChatRepository chatRepository;

  ChatController({
    required this.sendMessageUseCase,
    required this.chatRepository,
  });

  final messages = <MessageEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isLoadingCategory = false.obs; // For category item selection
  final services = <dynamic>[].obs;
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  // Pagination tracking
  final Map<String, int> _paginationState = {}; // messageId -> currentOffset

  @override
  void onInit() {
    super.onInit();
    _initChat();
  }

  Future<void> _initChat() async {
    isLoading.value = true;
    try {
      // Add welcome message
      messages.add(MessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
        'Hello! 👋 I\'m your personal service assistant. How can I help you today?',
        type: MessageType.bot,
        timestamp: DateTime.now(),
      ));
    } catch (e,st) {
      developer.log('Error$e', stackTrace: st);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    messages.add(MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      type: MessageType.user,
      timestamp: DateTime.now(),
    ));

    messageController.clear();
    _scrollToBottom();

    // Add typing indicator
    messages.add(MessageEntity(
      id: 'typing',
      content: '',
      type: MessageType.bot,
      timestamp: DateTime.now(),
      isTyping: true,
    ));

    try {
      final response = await sendMessageUseCase(text, services);

      // Remove typing indicator
      messages.removeWhere((m) => m.id == 'typing');

      // Initialize pagination tracking for this message
      if (response.searchQuery != null) {
        _paginationState[response.id] = 1; // Start at offset 1
      }

      // Add bot response
      messages.add(response);

      _scrollToBottom();
    } catch (e) {
      messages.removeWhere((m) => m.id == 'typing');
      Get.snackbar(
        'Error',
        'Failed to get response. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Handle category item selection - fetch services for the selected item
  Future<void> selectCategoryItem(String item) async {
    if (isLoadingCategory.value) return;

    isLoadingCategory.value = true;
    try {
      developer.log('Category item selected: $item', name: 'ChatController');

      // Add user message showing selected item
      messages.add(MessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: item,
        type: MessageType.user,
        timestamp: DateTime.now(),
      ));


      // Add typing indicator
      messages.add(MessageEntity(
        id: 'typing',
        content: '',
        type: MessageType.bot,
        timestamp: DateTime.now(),
        isTyping: true,
      ));

      // Fetch services for the selected item
      developer.log('Fetching services for: $item', name: 'ChatController');

      // Create a search response for the category item
      final searchResults = await chatRepository.loadMoreServices(
        item,
        limit: 5,
        offset: 1,
      );

      // Remove typing indicator
      messages.removeWhere((m) => m.id == 'typing');

      // Create bot message with services
      final response = MessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Great! Here are the $item I found:',
        type: MessageType.bot,
        timestamp: DateTime.now(),
        services: searchResults,
        searchQuery: item, // Store for pagination
      );

      // Initialize pagination for this message
      _paginationState[response.id] = 1;

      messages.add(response);
      _scrollToBottom();

      developer.log('Services loaded for category item: ${searchResults.length} results', name: 'ChatController');
    } catch (e) {
      developer.log('Error selecting category item: $e', name: 'ChatController');
      messages.removeWhere((m) => m.id == 'typing');
      Get.snackbar(
        'Error',
        'Failed to load services. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingCategory.value = false;
    }
  }

  /// Load more services for a specific message
  Future<void> loadMoreServices(String messageId) async {
    if (isLoadingMore.value) return;

    // Find the message
    final messageIndex = messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final message = messages[messageIndex];
    if (message.searchQuery == null || message.searchQuery!.isEmpty) return;

    isLoadingMore.value = true;
    try {
      final currentOffset = _paginationState[messageId] ?? 1;
      final nextOffset = currentOffset + 5; // Next page (increment by 5)

      developer.log('Loading more services: messageId=$messageId, offset=$nextOffset', name: 'ChatController');

      final moreServices = await chatRepository.loadMoreServices(
        message.searchQuery!,
        limit: 5,
        offset: nextOffset,
      );

      if (moreServices.isNotEmpty) {
        // Update pagination state
        _paginationState[messageId] = nextOffset;

        // Add new services to the message
        final updatedServices = [
          ...(message.services ?? []),
          ...moreServices,
        ];

        // Update the message with new services
        messages[messageIndex] = MessageEntity(
          id: message.id,
          content: message.content,
          type: message.type,
          timestamp: message.timestamp,
          services: updatedServices,
          searchQuery: message.searchQuery,
          categoryData: message.categoryData,
        );

        // Trigger UI update
        messages.refresh();

        developer.log('Added ${moreServices.length} more services. Total: ${updatedServices.length}', name: 'ChatController');
      } else {
        developer.log( 'No More Services, No additional services available.', name: 'ChatController');

      }
    } catch (e) {
      developer.log('Error loading more services: $e', name: 'ChatController');
      Get.snackbar(
        'Error',
        'Failed to load more services. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}