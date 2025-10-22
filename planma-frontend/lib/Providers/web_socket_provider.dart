import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketProvider extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final StreamController<Map<String, dynamic>> _reminderController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get reminderStream => _reminderController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _studentId;
  String? get studentId => _studentId;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  WebSocketProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl =
        dotenv.env['API_URL'] ?? 'https://planma-app-production.up.railway.app';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  // Initialize WebSocket with authentication check
  Future<void> initialize({BuildContext? context}) async {
    print('Initializing WebSocket provider');

    // First check if user is authenticated
    if (!await _checkAuthentication()) {
      print('User is not authenticated, skipping WebSocket connection');
      return;
    }

    // User is authenticated, proceed to get student ID
    await _getStudentId();

    if (_studentId != null) {
      await _connectWebSocket();
    } else {
      print('Failed to get student ID, cannot connect WebSocket');

      // Try to fetch user profile if student_id not found and context is available
      if (context != null) {
        await _tryFetchStudentIdFromProfile(context);
      }
    }
  }

  // Check if user is authenticated
  Future<bool> _checkAuthentication() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access');
      final refreshToken = prefs.getString('refresh');

      // Check if tokens exist
      if (accessToken == null && refreshToken == null) {
        _isAuthenticated = false;
        return false;
      }

      // You could add token validation logic here
      // For example, check if token is expired

      _isAuthenticated = true;
      return true;
    } catch (e) {
      print('Error checking authentication: $e');
      _isAuthenticated = false;
      return false;
    }
  }

  // Try to get student ID from multiple sources
  Future<void> _getStudentId() async {
    if (!_isAuthenticated) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Debug all keys in shared preferences
      final keys = prefs.getKeys();
      print('All SharedPreferences keys:');
      for (var key in keys) {
        print(' - $key: ${prefs.get(key)}');
      }

      // Try to get student_id directly
      _studentId = prefs.getString('student_id');
      if (_studentId != null) {
        print('Found student_id in shared preferences: $_studentId');
        return;
      }

      // Try to get user profile data which might contain student_id
      final userProfileData = prefs.getString('user_profile');
      if (userProfileData != null) {
        try {
          final profileData = jsonDecode(userProfileData);
          _studentId = _extractId(profileData, 'student_id') ??
              _extractId(profileData, 'id');

          if (_studentId != null) {
            print('Found student_id in user profile data: $_studentId');
            // Save it for future use
            await prefs.setString('student_id', _studentId!);
            return;
          }
        } catch (e) {
          print('Error parsing user profile data: $e');
        }
      }

      // Try to extract from JWT token
      final accessToken = prefs.getString('access');
      if (accessToken != null) {
        _studentId = _extractStudentIdFromToken(accessToken);
        if (_studentId != null) {
          print('Extracted student_id from JWT token: $_studentId');
          // Save it for future use
          await prefs.setString('student_id', _studentId!);
          return;
        }
      }

      // If we get here, we couldn't find the student_id
      print('Failed to find student_id in shared preferences');
    } catch (e) {
      print('Error getting student ID: $e');
    }
  }

  // Extract ID from various field names
  String? _extractId(Map<String, dynamic> data, String fieldName) {
    if (data[fieldName] != null) {
      return data[fieldName].toString();
    }
    return null;
  }

  // Extract student ID from JWT token
  String? _extractStudentIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Get the payload part and handle padding
      String payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      // Decode the base64 string
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final tokenData = jsonDecode(decoded);

      print('JWT token payload: $tokenData');

      // Try various possible ID field names
      return tokenData['student_id']?.toString() ??
          tokenData['user_id']?.toString() ??
          tokenData['id']?.toString() ??
          tokenData['sub']?.toString();
    } catch (e) {
      print('Error extracting student ID from token: $e');
      return null;
    }
  }

  // Try to fetch student ID from user profile API
  Future<void> _tryFetchStudentIdFromProfile(BuildContext context) async {
    if (!_isAuthenticated) return;

    try {
      // Example API request (adjust according to your API)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access');

      if (accessToken != null) {
        final response = await http.get(
          Uri.parse('$_baseApiUrl/user-profile/'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _studentId = data['student_id']?.toString() ?? data['id']?.toString();

          if (_studentId != null) {
            print('Fetched student_id from API: $_studentId');
            // Save for future use
            prefs.setString('student_id', _studentId!);
            // Now try to connect with the ID we got
            await _connectWebSocket();
          }
        } else {
          print('Failed to fetch user profile: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching student ID from profile: $e');
    }
  }

  // Connect to WebSocket server
  Future<void> _connectWebSocket() async {
    if (_isConnected || _studentId == null || !_isAuthenticated) return;

    try {
      print('Connecting to WebSocket with student_id: $_studentId');

      // Build the WebSocket URL with student ID
      final wsBase =
          dotenv.env['WS_URL'] ?? 'wss://planma-app-production.up.railway.app';
      final wsUrl = Uri.parse('$wsBase/ws/reminders/$studentId/');
      print('WebSocket URL: $wsUrl');

      _channel = WebSocketChannel.connect(wsUrl);

      _subscription = _channel!.stream.listen(
        (dynamic message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _isConnected = false;
          notifyListeners();
          // Attempt to reconnect after delay if still authenticated
          if (_isAuthenticated) {
            Future.delayed(Duration(seconds: 5), () => _connectWebSocket());
          }
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          notifyListeners();
          // Attempt to reconnect after delay if still authenticated
          if (_isAuthenticated) {
            Future.delayed(Duration(seconds: 5), () => _connectWebSocket());
          }
        },
      );

      _isConnected = true;
      print('WebSocket connected successfully');
      notifyListeners();

      // Request initial reminders after connection
      checkReminders();
    } catch (e) {
      print('WebSocket connection error: $e');
      _isConnected = false;
      notifyListeners();
      // Attempt to reconnect after delay if still authenticated
      if (_isAuthenticated) {
        Future.delayed(Duration(seconds: 5), () => _connectWebSocket());
      }
    }
  }

  // Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    if (!_isAuthenticated) return;

    try {
      print('Received WebSocket message: $message');
      final data = jsonDecode(message as String);

      if (data['type'] == 'reminder') {
        print('Processing reminder: ${data['reminder_type']}');
        // Forward the reminder to listeners
        _reminderController.add(data);
        notifyListeners();
      }
    } catch (e) {
      print('Error processing WebSocket message: $e');
    }
  }

  // Check for reminders - called after connection established
  void checkReminders() {
    if (_isConnected && _channel != null && _isAuthenticated) {
      print('Requesting reminder check');
      _channel!.sink.add(jsonEncode({'type': 'check_reminders'}));
    } else {
      print('Cannot check reminders - not connected or not authenticated');
    }
  }

  // Send a custom message to the WebSocket server
  void sendMessage(Map<String, dynamic> data) {
    if (_isConnected && _channel != null && _isAuthenticated) {
      _channel!.sink.add(jsonEncode(data));
    } else {
      print('Cannot send message - not connected or not authenticated');
    }
  }

  // Handle user authentication
  Future<void> onUserAuthenticated() async {
    _isAuthenticated = true;
    await initialize();
  }

  // Handle user logout
  void onUserLogout() {
    _isAuthenticated = false;
    disconnect();
  }

  // Disconnect from WebSocket server
  Future<void> disconnect() async {
    print('Disconnecting WebSocket');
    _isConnected = false;
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    notifyListeners();
  }

  // Force refresh connection
  Future<void> refreshConnection({BuildContext? context}) async {
    print('Refreshing WebSocket');
    await disconnect();
    await initialize(context: context);
  }

  @override
  void dispose() {
    disconnect();
    _reminderController.close();
    super.dispose();
  }
}
