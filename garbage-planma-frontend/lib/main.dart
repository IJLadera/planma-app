import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:planma_app/Notifications/local_notification_service.dart';
import 'package:planma_app/app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔥 Handling background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await LocalNotificationService.initialize();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Get and log token
  String? token = await _firebaseMessaging.getToken();
  print("🚀 FCM Token at startup: $token");

  // Listen to token refresh
  _firebaseMessaging.onTokenRefresh.listen((newToken) {
    print("🔁 Refreshed FCM Token: $newToken");
    // Optionally: _sendTokenToServer(newToken, authToken);
  });

  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
  print('User granted permission: ${settings.authorizationStatus}');

  // Testing: Access the base URL
  // String apiUrl = Config().baseApiUrl;
  // print(apiUrl);
  
  runApp(MyApp());
}
