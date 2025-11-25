import 'dart:convert';
import 'dart:developer' as developer;
import '../../../../core/utils/service_matcher.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/gemini_datasource.dart';
import '../datasources/service_datasource.dart';
import '../models/bot_response_model.dart';
import '../models/service_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final GeminiDataSource geminiDataSource;
  final ServiceDataSource serviceDataSource;

  ChatRepositoryImpl({
    required this.geminiDataSource,
    required this.serviceDataSource,
  });

  @override
  Future<MessageEntity> sendMessage(String message,
      List<dynamic> services,) async {
    try {
      developer.log('➡️ sendMessage called', name: 'ChatRepository');

      // 1️⃣ Send user message to Gemini (get full model reply)
      developer.log('Sending to Gemini: $message', name: 'ChatRepository');
      final res = await geminiDataSource.sendMessage(message);
      developer.log('From Gemini: $res', name: 'ChatRepository');

      final geminiResponse = BotResponseModel.fromJson(jsonDecode(res));



      return MessageEntity(
        id: DateTime
            .now()
            .millisecondsSinceEpoch
            .toString(),
        content: geminiResponse.data?.botData.message??'I\'m sorry',
        type: MessageType.bot,
        timestamp: DateTime.now(),
        // services: searchResults,
        // searchQuery: ,
        // Store query for pagination
        categoryData: geminiResponse.data?.botData.extra, // Store category data for UI display
      );
    } catch (e, st) {
      developer.log('❌ sendMessage failed: $e', name: 'ChatRepository',
          error: e,
          stackTrace: st);
      throw Exception('Failed to send message: $e');
    }
  }

  /// Load more services with pagination
  Future<List<ProductItemModel>> loadMoreServices(String query,
      {int limit = 5, int offset = 1}) async {
    try {
      developer.log(
          'Loading more services for: $query, limit: $limit, offset: $offset',
          name: 'ChatRepository');
      final results = await serviceDataSource.searchServices(
          query, limit: limit, offset: offset);
      developer.log(
          'Loaded ${results.length} more services', name: 'ChatRepository');
      return results;
    } catch (e, st) {
      developer.log('Error loading more services: $e', name: 'ChatRepository',
          error: e,
          stackTrace: st);
      throw Exception('Failed to load more services: $e');
    }
  }

/// 🔍 Extract category data from JSON block if available


/// 🔍 Robust extractor: supports exact markers, markers with surrounding whitespace,
/// and fallback to any JSON containing product_or_service.
}
