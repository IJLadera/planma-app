enum ClockContextType {
  task,       // For tracking time spent on a specific task
  activity,   // For tracking time spent on a specific activity
  sleep,      // For tracking sleep time
  goal,       // For tracking goal session time
}

class ClockContext {
  final ClockContextType type;

  ClockContext({
    required this.type,
  });
}