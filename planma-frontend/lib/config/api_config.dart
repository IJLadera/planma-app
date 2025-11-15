class ApiConfig {
  // Change this to your Railway deployment URL
  static const String _prodBaseUrl = "https://planma-app-production.up.railway.app";

  // ---- PUBLIC BASE URL ----
  static String get baseUrl => _prodBaseUrl;
}