
class SearchApi {
  final String name;
  final String searchUrl;

  final Map<String, String> headers;
  final Map<String, dynamic>? defaultBodyTemplate;
  final Duration? timeout;

  const SearchApi({
    required this.name,
    required this.searchUrl,
    this.headers = const {},
    this.defaultBodyTemplate,
    this.timeout,
  });

  /// Build URL with pagination parameters (limit and offset)
  String buildSearchUrl({String query = '', int limit = 10, int offset = 1}) {
    final separator = searchUrl.contains('?') ? '&' : '?';
    return '$searchUrl${separator}search=$query&limit=$limit&offset=$offset';
  }

  @override
  String toString() => 'SearchApi($name, $searchUrl)';
}
