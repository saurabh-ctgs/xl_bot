import 'package:flutter_sales_bot/src/core/utils/service_matcher.dart';

// class BotResponseModel {
//   final bool success;
//   final String response;
//   final Usage usage;
//   final String model;
//   final String platform;
//   final String ? botMsg;
//   final CategoryData ? categoryData;
//
//   BotResponseModel({
//     required this.success,
//     required this.response,
//     required this.usage,
//     required this.model,
//     required this.platform,
//     this.botMsg,
//     this.categoryData,
//   });
//
//   factory BotResponseModel.fromJson(Map<String, dynamic> json) {
//     return BotResponseModel(
//       success: json['success'] ?? false,
//       response: json['response'] ?? '',
//       usage: Usage.fromJson(json['usage'] ?? {}),
//       model: json['model'] ?? '',
//       platform: json['platform'] ?? '',
//       botMsg: ServiceMatcher.removeJsonBlock(json['response'] ?? ''),
//       categoryData: ServiceMatcher.extractCategoryData(json['response'] ?? '')!=null?CategoryData.fromJson(ServiceMatcher.extractCategoryData(json['response'] ?? '')!):null
//     );
//   }
// }


class Usage {
  final int promptTokens;
  final int responseTokens;
  final int totalTokens;
  final String geminiApiKey;

  Usage({
    required this.promptTokens,
    required this.responseTokens,
    required this.totalTokens,
    required this.geminiApiKey,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['promptTokens'] ?? 0,
      responseTokens: json['responseTokens'] ?? 0,
      totalTokens: json['totalTokens'] ?? 0,
      geminiApiKey: json['geminiApiKey'] ?? '',
    );
  }
}

class CategoryData {
  final String category;
  final List<String> items;

  CategoryData({
    required this.category,
    required this.items,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      category: json['category'] ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'items': items,
    };
  }
}


class BotResponseModel {
  final bool success;
  final String message;
  final ResponseData? data;

  BotResponseModel({
    required this.success,
    required this.message,
     this.data,
  });

  factory BotResponseModel.fromJson(Map<String, dynamic> json) {
    return BotResponseModel(
      success: json['success'],
      message: json['message'],
      data: ResponseData.fromJson(json['data']),
    );
  }
}

class ResponseData {
  final BotData botData;
  final ModelData modelData;
  final Usage usage;

  ResponseData({
    required this.botData,
    required this.modelData,
    required this.usage,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      botData: BotData.fromJson(json['bot_data']),
      modelData: ModelData.fromJson(json['model_data']),
      usage: Usage.fromJson(json['usage']),
    );
  }
}

class BotData {
  final String? message;
  final Extra? extra;

  BotData({
     this.message,
     this.extra,
  });

  factory BotData.fromJson(Map<String, dynamic> json) {
    return BotData(
      message: json['message'],
      extra: Extra.fromJson(json['extra']),
    );
  }
}

class Extra {
  final String? category;
  final List<String> items;

  Extra({
    required this.category,
    required this.items,
  });

  factory Extra.fromJson(Map<String, dynamic> json) {
    return Extra(
      category: json['category'],
      items: List<String>.from(json['items']),
    );
  }
}

class ModelData {
  final String model;
  final String platform;

  ModelData({
    required this.model,
    required this.platform,
  });

  factory ModelData.fromJson(Map<String, dynamic> json) {
    return ModelData(
      model: json['model'],
      platform: json['platform'],
    );
  }
}


