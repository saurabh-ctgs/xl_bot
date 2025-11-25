import 'dart:convert';
import 'dart:developer' as developer;

import '../../features/chat/data/models/service_model.dart';

class ServiceMatcher {
  static List<Service> matchServices(String message, List<Service> services) {
    final lowerMessage = message.toLowerCase();
    final matches = <Service>[];

    for (var service in services) {
      final serviceName = service.name?.toLowerCase() ?? '';
      final description = service.shortDescription?.toLowerCase() ?? '';

      if (lowerMessage.contains(serviceName) ||
          serviceName.contains(lowerMessage) ||
          description.contains(lowerMessage)) {
        matches.add(service);
      }
    }

    return matches;
  }


  static String extractKeywordFromResponse(String response) {
    try {
      if (response.isEmpty) return 'unknown';

      // 1) Look for exact marker block
      final startMarker = '===EXTRA_JSON_START===';
      final endMarker = '===EXTRA_JSON_END===';
      final start = response.indexOf(startMarker);
      final end = response.indexOf(endMarker);

      if (start != -1 && end != -1 && end > start) {
        final jsonBlock = response.substring(start + startMarker.length, end).trim();
        final match = RegExp(r'"product_or_service"\s*:\s*"([^"]+)"').firstMatch(jsonBlock);
        if (match != null) return match.group(1) ?? 'unknown';
      }

      // 2) Also handle the case where model put JSON inside a fenced code block ```json ... ```
      final codeBlockMatch = RegExp(r'```(?:json)?\s*({[\s\S]*?})\s*```', multiLine: true).firstMatch(response);
      if (codeBlockMatch != null) {
        final jsonText = codeBlockMatch.group(1)!;
        final match = RegExp(r'"product_or_service"\s*:\s*"([^"]+)"').firstMatch(jsonText);
        if (match != null) return match.group(1) ?? 'unknown';
      }

      // 3) Last resort: find any JSON object in the response and search for the key
      final anyJsonMatch = RegExp(r'({[\s\S]*?})').allMatches(response);
      for (final m in anyJsonMatch) {
        final jsonText = m.group(1)!;
        final match = RegExp(r'"product_or_service"\s*:\s*"([^"]+)"').firstMatch(jsonText);
        if (match != null) return match.group(1) ?? 'unknown';
      }

      return 'unknown';
    } catch (e, st) {
      developer.log('Error extracting keyword: $e', name: 'ChatRepository', error: e, stackTrace: st);
      return 'unknown';
    }
  }

  /// ✂️ Removes known JSON block variants before showing text in chat
  static String removeJsonBlock(String raw) {
    if (raw.isEmpty) return raw;

    try {
      String response = raw;

      // If the text looks double-serialized (contains literal backslash-n or backslash-quote),
      // convert those to real newlines/quotes so indexOf on markers works consistently.
      // We only unescape common sequences (safe, reversible-ish).
      bool looksEscaped = response.contains(r'\n') || response.contains(r'\"') || response.contains(r'\\');
      if (looksEscaped) {
        response = unescapeCommon(response);
      }

      const startMarker = '===EXTRA_JSON_START===';
      const endMarker = '===EXTRA_JSON_END===';

      // Find markers by index (non-greedy, deterministic)
      final startIdx = response.indexOf(startMarker);
      if (startIdx == -1) {
        // nothing to remove
        return response.trim();
      }

      // Look for end marker after start marker
      var endIdx = response.indexOf(endMarker, startIdx + startMarker.length);
      if (endIdx == -1) {
        // handle common variant where there's an extra trailing quote after end marker:
        final alt = endMarker + '"';
        endIdx = response.indexOf(alt, startIdx + startMarker.length);
        if (endIdx != -1) {
          // endIdx points to start of alt; treat as found and include alt length
          endIdx += alt.length;
          // remove from start up to endIdx
          String cleaned = response.replaceRange(startIdx, endIdx, '');
          return cleaned.trim();
        }
        // end marker not found — be conservative: remove from start marker to end of line only
        final nextLineIdx = response.indexOf('\n', startIdx + startMarker.length);
        if (nextLineIdx != -1) {
          String cleaned = response.replaceRange(startIdx, nextLineIdx + 1, '');
          return cleaned.trim();
        }
        // fallback: nothing else we can do safely
        return response.trim();
      }

      // Normal case: end marker found — remove inclusive block
      final removeEnd = endIdx + endMarker.length;
      // If there's immediately an extra quote after the end marker, drop it as well
      if (removeEnd < response.length && response[removeEnd] == '"') {
        // include the quote in removal
        final cleaned = response.replaceRange(startIdx, removeEnd + 1, '');
        return cleaned.trim();
      } else {
        final cleaned = response.replaceRange(startIdx, removeEnd, '');
        return cleaned.trim();
      }
    } catch (e, st) {
      developer.log('removeJsonBlockSafely error: $e', error: e, stackTrace: st, name: 'ChatRepository');
      return raw;
    }
  }

  static String unescapeCommon(String s) {
    var t = s;
    // first reduce double-escaped backslashes to single (\\\\ -> \\)
    t = t.replaceAll(r'\\\\', r'\\');
    // then replace common visible escape sequences with actual chars
    t = t.replaceAll(r'\n', '\n');
    t = t.replaceAll(r'\r', '\r');
    t = t.replaceAll(r'\t', '\t');
    t = t.replaceAll(r'\"', '"');
    t = t.replaceAll(r"\'", "'");
    return t;
  }


  static Map<String, dynamic>? extractCategoryData(String response) {
    try {
      if (response.isEmpty) return null;

      // Clean top-level accidental trailing quotes/whitespace
      response = response.trim().replaceAll(RegExp(r'"+$'), '');

      const startMarker = '===EXTRA_JSON_START===';
      const endMarker = '===EXTRA_JSON_END===';

      final start = response.indexOf(startMarker);
      final end = response.indexOf(endMarker);

      if (start == -1 || end == -1 || end <= start) return null;

      String jsonBlock = response.substring(start + startMarker.length, end).trim();

      // Helper: try decode and return if success
      Map<String, dynamic>? tryDecode(String s) {
        try {
          final decoded = jsonDecode(s);
          if (decoded is Map<String, dynamic>) return decoded;
          return null;
        } catch (e) {
          return null;
        }
      }

      // 1) Try decode raw
      var parsed = tryDecode(jsonBlock);
      if (parsed != null) {
        developer.log('Parsed JSON (raw)', name: 'ChatRepository');
        if (parsed.containsKey('category') && parsed.containsKey('items')) return parsed;
        return parsed;
      }

      // 2) If block is wrapped in quotes like "\"{...}\"" or "\"...\""
      if ((jsonBlock.startsWith('"') && jsonBlock.endsWith('"')) ||
          (jsonBlock.startsWith("'") && jsonBlock.endsWith("'"))) {
        final unwrapped = jsonBlock.substring(1, jsonBlock.length - 1);
        parsed = tryDecode(unwrapped);
        if (parsed != null) {
          developer.log('Parsed JSON (unwrapped quoted string)', name: 'ChatRepository');
          if (parsed.containsKey('category') && parsed.containsKey('items')) return parsed;
          return parsed;
        }
      }

      // 3) Attempt to unescape common escape sequences (\\n, \\", \\\\ => \, etc.)
      String unescapeCommon(String s) {
        // Replace literal backslash-n (two chars: '\' and 'n') with actual newline,
        // and handle common escapes produced by double-serialization.
        var t = s;
        t = t.replaceAll(r'\n', '\n');
        t = t.replaceAll(r'\r', '\r');
        t = t.replaceAll(r'\t', '\t');
        t = t.replaceAll(r'\"', '"');
        t = t.replaceAll(r"\'", "'");
        // Reduce double-escaped backslashes to single backslash
        t = t.replaceAll(r'\\', r'\');
        return t;
      }

      final cleaned = unescapeCommon(jsonBlock).trim();
      parsed = tryDecode(cleaned);
      if (parsed != null) {
        developer.log('Parsed JSON (cleaned escapes)', name: 'ChatRepository');
        if (parsed.containsKey('category') && parsed.containsKey('items')) return parsed;
        return parsed;
      }

      // 4) As last attempt: remove any leading control characters/newlines then try
      final stripped = cleaned.replaceFirst(RegExp(r'^[\s\p{C}]+', unicode: true), '');
      parsed = tryDecode(stripped);
      if (parsed != null) {
        developer.log('Parsed JSON (stripped control chars)', name: 'ChatRepository');
        if (parsed.containsKey('category') && parsed.containsKey('items')) return parsed;
        return parsed;
      }

      developer.log('All JSON parsing attempts failed', name: 'ChatRepository');
      return null;
    } catch (e, st) {
      developer.log('Error extracting category data: $e', name: 'ChatRepository', error: e, stackTrace: st);
      return null;
    }
  }
}
