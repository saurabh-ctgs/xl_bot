class LightweightKeywordExtractor {
  static final _stopwords = <String>{
    'the','is','in','at','which','on','and','a','an','for','to','with','of','by','from','as','that','this','it','be','are','or','so','if','but','we','you','i','me','my'
  };

  List<String> extract(String text, int topN) {
    if (text.trim().isEmpty) return [];
    final lowered = text.toLowerCase();
    final cleaned = lowered.replaceAll(RegExp(r'[^\w\s\-]'), ' ');
    final parts = cleaned.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();

    final Map<String, int> freq = {};
    for (int i = 0; i < parts.length; i++) {
      for (int len = 1; len <= 3 && i + len <= parts.length; len++) {
        final seg = parts.sublist(i, i + len);
        if (seg.any((t) => _stopwords.contains(t))) continue;
        final phrase = seg.join(' ');
        freq[phrase] = (freq[phrase] ?? 0) + 1;
      }
    }

    if (freq.isEmpty) {
      final counts = <String, int>{};
      for (final t in parts) {
        if (_stopwords.contains(t)) continue;
        counts[t] = (counts[t] ?? 0) + 1;
      }
      final fallback = counts.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
      return fallback.take(topN).map((e) => e.key).toList();
    }

    final sorted = freq.entries.toList()
      ..sort((a,b) {
        final cmp = b.value.compareTo(a.value);
        if (cmp != 0) return cmp;
        return b.key.split(' ').length.compareTo(a.key.split(' ').length);
      });

    return sorted.take(topN).map((e) => e.key).toList();
  }
}
