// lib/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';


class WebSocketService with ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  String? _latestMessage;
  Map<String, dynamic>? _latestReminder;

  bool get isConnected => _isConnected;
  String? get latestMessage => _latestMessage;
  Map<String, dynamic>? get latestReminder => _latestReminder;

  // Connect to Django WebSocket server
  void connect(String url) {
    try {
      _channel = IOWebSocketChannel.connect(url);
      _isConnected = true;

      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          _isConnected = false;
          notifyListeners();
          if (kDebugMode) {
            print('WebSocket disconnected');
          }
        },
        onError: (error) {
          _isConnected = false;
          notifyListeners();
          if (kDebugMode) {
            print('WebSocket error: $error');
          }
        },
      );

      notifyListeners();
      if (kDebugMode) {
        print('WebSocket connected to $url');
      }

      // Send a ping to test the connection
      sendMessage({'action': 'ping'});
    } catch (e) {
      _isConnected = false;
      notifyListeners();
      if (kDebugMode) {
        print('WebSocket connection failed: $e');
      }
    }
  }

  // Send message to server
  void sendMessage(Map<String, dynamic> data) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(data));
    } else {
      if (kDebugMode) {
        print('Cannot send message, WebSocket not connected');
      }
    }
  }

  // Handle incoming messages
  void _handleMessage(dynamic message) {
    _latestMessage = message.toString();

    try {
      final data = jsonDecode(message);

      if (data['type'] == 'reminder') {
        _latestReminder = data;
        notifyListeners();
      }

      if (kDebugMode) {
        print('Received message: $data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing message: $e');
      }
    }

    notifyListeners();
  }

  // Request a test reminder
  void requestTestReminder() {
    sendMessage({'action': 'test_reminder'});
  }

  // Request to send reminders based on user preferences
  void requestReminders() {
    sendMessage({'action': 'send_reminder'});
  }

  // Dismiss current reminder
  void dismissReminder() {
    _latestReminder = null;
    notifyListeners();
  }

  // Disconnect from WebSocket
  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    notifyListeners();
    if (kDebugMode) {
      print('WebSocket disconnected');
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
