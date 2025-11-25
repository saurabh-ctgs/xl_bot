import 'api.dart';

typedef BeforeSearchCallback = void Function(String query, List<String> keywords);
typedef OnResultCallback = void Function(String apiName, Map<String, dynamic> rawResult);

class SalesBotConfig {
  final String projectId;
  final List<SearchApi> searchApis;
  final Duration defaultTimeout;
  final int topKeywordCount;
  final BeforeSearchCallback? onBeforeSearch;
  final OnResultCallback? onResult;

  const SalesBotConfig({
    required this.projectId,
    required this.searchApis,
    this.defaultTimeout = const Duration(seconds: 8),
    this.topKeywordCount = 5,
    this.onBeforeSearch,
    this.onResult,
  }) : assert(searchApis.length > 0, 'At least one SearchApi must be provided');
}

/// Singleton manager for SalesBotConfig
/// Initialize once with [SalesBotConfigManager.initialize(config)]
/// Access globally with [SalesBotConfigManager.instance.config]
class SalesBotConfigManager {
  static final SalesBotConfigManager _instance = SalesBotConfigManager._internal();
  SalesBotConfig? _config;

  SalesBotConfigManager._internal();

  static SalesBotConfigManager get instance => _instance;

  /// Initialize the config - should be called once in main.dart or app initialization
  static void initialize(SalesBotConfig config) {
    _instance._config = config;
  }

  /// Get the initialized config
  SalesBotConfig get config {
    if (_config == null) {
      throw Exception(
        'SalesBotConfig not initialized. Call SalesBotConfigManager.initialize(config) before accessing config.',
      );
    }
    return _config!;
  }

  /// Check if config is initialized
  bool get isInitialized => _config != null;
}
