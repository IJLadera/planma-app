import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final StreamController<Map<String, dynamic>> _reminderController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Expose stream to listen for reminders
  Stream<Map<String, dynamic>> get reminderStream => _reminderController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String? _studentId;

  // Connect to the WebSocket server
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // Get student ID from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // print('Preferences: ');
      // print(prefs);

      _studentId = prefs.getString('student_id');

      if (_studentId == null) {
        throw Exception('Student ID not found in shared preferences');
      }

      // Create WebSocket connection
      final wsBase = dotenv.env['WS_URL'] ?? 'ws://localhost:8000';
      final wsUrl = Uri.parse('$wsBase/ws/reminders/$_studentId/');
      _channel = WebSocketChannel.connect(wsUrl);

      // Listen for messages
      _subscription = _channel!.stream.listen(
        (dynamic message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _isConnected = false;
          // Attempt to reconnect after delay
          Future.delayed(Duration(seconds: 5), () => connect());
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          // Attempt to reconnect after delay
          Future.delayed(Duration(seconds: 5), () => connect());
        },
      );

      _isConnected = true;
      print('WebSocket connected for student ID: $_studentId');

      // Request initial check for reminders
      checkReminders();
    } catch (e) {
      print('WebSocket connection error: $e');
      _isConnected = false;
      // Attempt to reconnect after delay
      Future.delayed(Duration(seconds: 5), () => connect());
    }
  }

  // Request a check for reminders
  void checkReminders() {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode({'type': 'check_reminders'}));
    }
  }

  // Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);

      if (data['type'] == 'reminder') {
        // Forward the reminder to listeners
        _reminderController.add(data);
      }
    } catch (e) {
      print('Error processing WebSocket message: $e');
    }
  }

  // Disconnect from the WebSocket server
  Future<void> disconnect() async {
    _isConnected = false;
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }

  // Dispose method to clean up resources
  void dispose() {
    disconnect();
    _reminderController.close();
  }
}
