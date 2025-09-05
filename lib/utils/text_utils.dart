class TextUtils {
  static final Set<String> _stopwords = {
    'the','a','an','and','or','but','to','of','in','on','for','with','at','by','from','as','is','it','this','that','these','those','be','are','was','were','am','i','you','he','she','we','they','do','did','does','have','has','had','my','your','our','their'
  };

  static String normalizeTitle(String input) {
    final collapsed = input.trim().toLowerCase().replaceAll(RegExp(r"\s+"), ' ');
    return collapsed;
  }

  static List<String> tokenize(String input) {
    final lower = input.toLowerCase();
    final raw = lower.split(RegExp(r"[^a-z0-9]+"));
    final tokens = <String>[];
    for (final t in raw) {
      if (t.isEmpty) continue;
      if (_stopwords.contains(t)) continue;
      tokens.add(t);
    }
    return tokens;
  }

  static double jaccard<T>(Set<T> a, Set<T> b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    final inter = a.intersection(b).length;
    final union = a.union(b).length;
    if (union == 0) return 0.0;
    return inter / union;
  }
}
