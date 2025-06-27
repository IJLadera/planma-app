import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:planma_app/Providers/web_socket_provider.dart';
import 'package:planma_app/features/authentication/presentation/providers/user_provider.dart';

class ReminderListener extends StatefulWidget {
  final Widget child;

  const ReminderListener({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ReminderListener> createState() => _ReminderListenerState();
}

class _ReminderListenerState extends State<ReminderListener> with WidgetsBindingObserver{
  bool _initialized = false;
  WebSocketProvider? _wsProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize WebSocket connection after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebSocket();
    });
  }

  void _initializeWebSocket() {
    // Get user provider to check authentication status
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _wsProvider = Provider.of<WebSocketProvider>(context, listen: false);

    // Only initialize if the user is authenticated
    if (userProvider.isAuthenticated) {
      if (!_initialized) {
        _wsProvider!.initialize(context: context);
        _initialized = true;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen for authentication changes
    final userProvider = Provider.of<UserProvider>(context);
    final webSocketProvider =
        Provider.of<WebSocketProvider>(context, listen: false);

    // If authentication status changed to authenticated, initialize WebSocket
    if (userProvider.isAuthenticated && !_initialized) {
      webSocketProvider.onUserAuthenticated();
      _initialized = true;
    }
    // If authentication status changed to unauthenticated, disconnect WebSocket
    else if (!userProvider.isAuthenticated && _initialized) {
      webSocketProvider.onUserLogout();
      _initialized = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_wsProvider == null) return;

    if (state == AppLifecycleState.resumed) {
      _wsProvider!.sendMessage({
        "type": "status_update",
        "foreground": true,
      });
      _wsProvider!.refreshConnection(context: context);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _wsProvider!.sendMessage({
        "type": "status_update",
        "foreground": false,
      });
      _wsProvider!.disconnect();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webSocketProvider = Provider.of<WebSocketProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Only listen to WebSocket if user is authenticated
    if (!userProvider.isAuthenticated) {
      return widget.child;
    }

    return StreamBuilder<Map<String, dynamic>>(
      stream: webSocketProvider.reminderStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Process the reminder data
          final reminderData = snapshot.data!;
          final reminderType = reminderData['reminder_type'];
          final reminder = reminderData['reminder'];

          // Show different types of reminders
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showReminderSnackBar(context, reminderType, reminder);
          });
        }

        // Return the child widget
        return widget.child;
      },
    );
  }

  void _showReminderSnackBar(
      BuildContext context, String reminderType, dynamic reminderData) {
    String message = '';
    IconData icon = Icons.notifications;
    Color color = Colors.blue;

    // Format reminder message based on type
    switch (reminderType) {
      case 'sleep':
        message = reminderData.toString();
        icon = Icons.bedtime;
        color = Colors.indigo;
        break;
      case 'wake':
        message = reminderData.toString();
        icon = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case 'task':
        final taskName = reminderData['name'] ?? 'Task';
        final hoursRemaining = reminderData['hours_remaining'] ?? 0;
        message = '$taskName due in $hoursRemaining hours';
        icon = Icons.task_alt;
        color = Colors.red;
        break;
      case 'event':
        final eventName = reminderData['name'] ?? 'Event';
        message = 'Upcoming event: $eventName';
        icon = Icons.event;
        color = Colors.purple;
        break;
      case 'class':
        final subjectTitle = reminderData['subject_title'] ?? 'Class';
        final room = reminderData['room'] ?? '';
        message = 'Class reminder: $subjectTitle in $room';
        icon = Icons.school;
        color = Colors.teal;
        break;
      case 'activity':
        final activityName = reminderData['name'] ?? 'Activity';
        message = 'Scheduled activity: $activityName';
        icon = Icons.directions_run;
        color = Colors.green;
        break;
      case 'goal':
        final goalName = reminderData['name'] ?? 'Goal';
        message = 'Goal reminder: $goalName';
        icon = Icons.flag;
        color = Colors.amber;
        break;
      default:
        message = 'New reminder received';
    }

    // Show the snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to appropriate screen based on reminder type
            _navigateToReminderDetails(context, reminderType, reminderData);
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToReminderDetails(
      BuildContext context, String reminderType, dynamic reminderData) {
    // Navigation logic based on reminder type
    switch (reminderType) {
      case 'task':
        print('Testing');
        // Navigate to task details
        // Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: reminderData['id'])));
        break;
      case 'event':
        // Navigate to event details
        // Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: reminderData['id'])));
        break;
      case 'class':
        // Navigate to class schedule
        // Navigator.push(context, MaterialPageRoute(builder: (_) => ClassScheduleScreen()));
        break;
      // Add cases for other reminder types
      default:
        // No specific navigation
        break;
    }
  }
}
