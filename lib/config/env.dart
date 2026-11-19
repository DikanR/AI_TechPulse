class Env {
  Env._();

  static const String baseUrl = String.fromEnvironment('GNEWS_BASE_URL');
  static const String apiKey = String.fromEnvironment('GNEWS_API_KEY');

  static bool get lengkap => baseUrl.isNotEmpty && apiKey.isNotEmpty;
  static bool get pakaiKeyLangsung => apiKey.isNotEmpty;

  /// Masks API keys in log text and error messages for privacy and security.
  static String samarkan(String text) {
    var result = text.replaceAllMapped(
      RegExp(r'(apikey=)[^&\s"]+', caseSensitive: false),
      (m) => '${m[1]}***',
    );
    if (apiKey.isNotEmpty) {
      result = result.replaceAll(apiKey, '***');
    }
    return result;
  }
}
