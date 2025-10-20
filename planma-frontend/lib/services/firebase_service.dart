import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initFCM(String authToken) async {
    String? token = await _firebaseMessaging.getToken();

    if (token != null) {
      await _sendTokenToServer(token, authToken);
    }

    // Refresh token if changed
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _sendTokenToServer(newToken, authToken);
    });
  }

  static Future<void> _sendTokenToServer(String token, String authToken) async {
    final baseUrl = dotenv.env['API_URL'] ??
        'http://https://planma-app-production.up.railway/';

    await http.post(
      Uri.parse("${baseUrl}api/fcm-token/register/"),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"token": token}),
    );
  }
}
