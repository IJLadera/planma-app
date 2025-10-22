import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Singleton pattern to ensure Config is initialized only once
  static final Config _instance = Config._internal();
  factory Config() => _instance;

  // Private constructor to initialize _baseApiUrl
  Config._internal() {
    _baseApiUrl = _loadBaseApiUrl();
  }

  // Getter for the base API URL
  String get baseApiUrl => _baseApiUrl;

  // Load the base URL from environment variables
  String _loadBaseApiUrl() {
    // Load the environment variables from .env file
    String? baseUrl = dotenv.env['API_URL'];

    // Default to localhost if API_URL is not provided
    if (baseUrl == null || baseUrl.isEmpty) {
      baseUrl = 'http://planma-app-production.up.railway.app';
    }

    // Remove trailing slash if present
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    return '$baseUrl/api';
  }
}
