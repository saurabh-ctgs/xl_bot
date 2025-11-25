<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# flutter_sales_bot

A Flutter chat/support bot UI and integration helper. This package provides a lightweight chat UI component and helpers to wire it to search/service APIs and an LLM (Gemini) datasource. It centralizes configuration via `SalesBotConfig` so your app and the package can access settings globally after a single initialization.

## Features

- Floating chat button (`SalesBotButton`) that opens a chat-style UI.
- Global configuration via `SalesBotConfig` and `SalesBotConfigManager`.
- Helpers for registering multiple `SearchApi` endpoints and building paginated search URLs.
- Example integration showing how to parse embedded JSON from Gemini LLM responses and show tappable item options.

## Getting started

### Prerequisites

- Flutter and Dart SDK matching the package `pubspec.yaml` environment (Dart >= 3.9.2).
- Run `flutter pub get` in the package and example directories to fetch dependencies.

### Install

If you're using this package locally in a project, add it as a path dependency in your app's `pubspec.yaml`. If published, add the package from pub.dev.

Example (local path):

```yaml
dependencies:
  flutter_sales_bot:
    path: ../flutter_sales_bot
```

Then run:

```bash
flutter pub get
```

## Quick initialization (required)

You must initialize the global configuration exactly once before using the package UI or datasources. Do this in `main()` prior to calling `runApp(...)`.

```dart
import 'package:flutter_sales_bot/flutter_sales_bot.dart';

void main() {
  final config = SalesBotConfig(
    projectId: 'your_project_id_here',
    searchApis: [
      SearchApi(
        name: 'Service provider',
        searchUrl: 'https://cityprofessionals.example.com/api/v1/customer/service/search',
      ),
      SearchApi(
        name: 'Blood test',
        searchUrl: 'https://911.example.com/api/patient/v2/fetch-all-packages',
      ),
    ],
    defaultTimeout: const Duration(seconds: 8),
    topKeywordCount: 5,
  );

  SalesBotConfigManager.initialize(config);

  runApp(const MyApp());
}
```

After this call you can access the config anywhere with:

```dart
final config = SalesBotConfigManager.instance.config;
```

## Using `SearchApi` and pagination

Each `SearchApi` contains a `searchUrl` and helper methods to build paginated search URLs.

- `SearchApi.buildSearchUrl({int limit = 10, int offset = 1})` appends `?limit=...&offset=...` to the configured `searchUrl`.

Important: confirm whether your backend expects `offset` to be a page number (1-based) or an item offset (0-based). Adjust usage accordingly.

Example fetch using `limit` and `offset`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchServicesPage(SearchApi api, {int limit = 10, required int offset, String? query}) async {
  var url = api.buildSearchUrl(limit: limit, offset: offset);
  // If your backend accepts a query param, append it. Otherwise send in request body as required.
  if (query != null) {
    url = '$url&query=${Uri.encodeComponent(query)}';
  }
  final response = await http.get(Uri.parse(url)).timeout(SalesBotConfigManager.instance.config.defaultTimeout);
  if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  return (data['items'] as List<dynamic>?) ?? [];
}
```

Pagination strategy (recommended):
- Choose a page size `limit` (e.g., 10 or 20).
- Start with `offset = 1` (or `0` if your backend is 0-based) and increment `offset` to load more pages.
- If your backend returns fewer results than `limit`, treat that as the end of results.

## Handling Gemini LLM responses with embedded JSON

The example Gemini responses may include an embedded JSON section between markers like:

```
===EXTRA_JSON_START===
{"category":"cleaning","items":["deep cleaning","regular cleaning",...]}
===EXTRA_JSON_END===
```

Use a robust extractor to parse that JSON safely:

```dart
import 'dart:convert';

Map<String, dynamic>? extractEmbeddedJson(String text) {
  const startMarker = '===EXTRA_JSON_START===';
  const endMarker = '===EXTRA_JSON_END===';
  final start = text.indexOf(startMarker);
  final end = text.indexOf(endMarker);
  if (start == -1 || end == -1 || end <= start) return null;
  final jsonText = text.substring(start + startMarker.length, end).trim();
  try {
    return jsonDecode(jsonText) as Map<String, dynamic>;
  } catch (e) {
    // handle parse error
    return null;
  }
}
```

If the extracted JSON includes a `category` and an `items` array, present the `items` as tappable options in the chat UI. When the user taps an option, call your service `SearchApi` with the chosen item as the query and load the first results page.

## Example UI flow: show items and load services

1. Extract `items` from Gemini response.
2. Render them as buttons or chips in the chat bubble (e.g., `ActionChip`, `OutlinedButton`).
3. On item tap, call a paginated fetch using the matching `SearchApi`.
4. Present results as cards/messages in the chat.
5. If more pages exist, show a "Load more" button. On tap, increment `offset` and fetch the next page.

Minimal example for handling item taps and pagination logic:

```dart
int currentOffset = 1;
const int pageSize = 10;
bool hasMore = true;

Future<void> loadServices(SearchApi api, String query, {bool reset = false}) async {
  if (reset) {
    currentOffset = 1;
    hasMore = true;
  }
  if (!hasMore) return;
  final items = await fetchServicesPage(api, limit: pageSize, offset: currentOffset, query: query);
  // add items to chat UI
  if (items.length < pageSize) hasMore = false;
  currentOffset += 1; // If backend expects page numbers
}
```

## Using the UI widget (`SalesBotButton`)

Add the floating chat button to your scaffold. The `example/` app demonstrates this usage. You can pass UI customization via `ChatUIConfig` and action buttons via `ActionButton`.

```dart
floatingActionButton: SalesBotButton(
  icon: const Icon(Icons.support_agent, size: 28),
  useGradient: true,
  size: 64,
  tooltip: 'Get Support',
  uiConfig: ChatUIConfig.light().copyWith(
    onTapDefaultActionButton: (value) { /* handle */ },
  ),
  actionButtons: [ /* ... */ ],
),
```

## Troubleshooting: UI render issues in cards

Common causes and fixes:

- Overflow in `Column` with unbounded `ListView`: wrap the scrollable with `Expanded` or set `shrinkWrap: true` on the inner list and a fixed height.
- Long text in `Row` causing overflow: wrap text in `Flexible` or `Expanded`.
- Nested scroll views: prefer a single scrollable or make inner scrollables non-scrollable with `NeverScrollableScrollPhysics()`.

Use the Flutter Inspector and console errors (e.g., "A RenderFlex overflowed by ...") to find root causes.

## Running the example

From the package root:

```bash
flutter pub get
cd example
flutter pub get
flutter run
```

If building on iOS (macOS):

```bash
cd example/ios
pod install
```

## Next steps & suggestions

- Add a reusable `GeminiJsonExtractor` utility class and an `ItemsOptionsWidget` to render LLM-returned choices.
- Add tests: unit tests for JSON extraction and integration tests for pagination.
- Confirm backend query/offset conventions (page number vs item offset) and adapt `offset` increment logic accordingly.

## Contributing

Contributions are welcome. Please open an issue or a pull request with a clear description and a minimal reproduction when applicable.

---

If you want, I can also add the `GeminiJsonExtractor` and a small `ItemsOptionsWidget` into the `example/` app and run the example to verify behavior — tell me which to add next and I'll implement and validate it.
