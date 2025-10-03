import 'dart:math';

import 'package:planma_app/models/sleep_log_model.dart';
import 'package:planma_app/reports/widget/class.dart';

class FeedbackService {
  // ---------- TASK FEEDBACK ----------
  static List<FeedbackEntry> generateTaskFeedback({
    required List<TaskTimeSpent> taskTimeSpent,
    required List<TaskTimeDistribution> taskTimeDistribution,
    required List<FinishedTask> taskFinished,
    required int totalTasks,
    double? previousTotalMinutes,
  }) {
    List<FeedbackEntry> feedback = [];

    // ---------- Task Completion Rate ----------
    if (totalTasks > 0) {
      int finished =
          taskFinished.isNotEmpty ? taskFinished.first.totalTaskFinished : 0;
      double rate = (finished / totalTasks) * 100;

      if (rate >= 80) {
        feedback.add(FeedbackEntry(
          sentiment: "positive",
          message:
              "Strong progress: ${rate.toStringAsFixed(0)}% of tasks completed.",
          category: "Tasks",
        ));
      } else if (rate >= 50) {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "Halfway there: ${rate.toStringAsFixed(0)}% of tasks completed.",
          category: "Tasks",
        ));
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "negative",
          message:
              "Low completion rate: only ${rate.toStringAsFixed(0)}% of tasks done.",
          category: "Tasks",
        ));
      }
    }

    // ---------- Time Spent Trend ----------
    if (taskTimeSpent.isNotEmpty) {
      double currentTotal = taskTimeSpent.fold(
        0,
        (sum, item) => sum + item.minutes,
      );

      if (previousTotalMinutes != null && previousTotalMinutes > 0) {
        double percentChange =
            ((currentTotal - previousTotalMinutes) / previousTotalMinutes) *
                100;

        if (percentChange >= 20) {
          feedback.add(
            FeedbackEntry(
              sentiment: "positive",
              message:
                  "Task time increased by ${percentChange.toStringAsFixed(0)}%. Great boost in focus!",
              category: "Tasks",
            ),
          );
        } else if (percentChange <= -20) {
          feedback.add(
            FeedbackEntry(
              sentiment: "negative",
              message:
                  "Task time dropped by ${percentChange.abs().toStringAsFixed(0)}%. Try to stay consistent.",
              category: "Tasks",
            ),
          );
        } else {
          feedback.add(
            FeedbackEntry(
              sentiment: "neutral",
              message:
                  "Task time stayed steady with a ${percentChange.toStringAsFixed(0)}% change.",
              category: "Tasks",
            ),
          );
        }
      } else {
        feedback.add(
          FeedbackEntry(
            sentiment: "neutral",
            message:
                "You logged ${_fmtMinutes(currentTotal)} on tasks. No previous data to compare.",
            category: "Tasks",
          ),
        );
      }
    }

    // ---------- Time Distribution ----------
    if (taskTimeDistribution.isNotEmpty) {
      // Get the total minutes spent across all subjects
      double totalMinutes = taskTimeDistribution.fold(
        0,
        (sum, item) => sum + item.percentage,
      );

      if (totalMinutes > 0) {
        // Sort so the subject with the most time comes first
        taskTimeDistribution
            .sort((a, b) => b.percentage.compareTo(a.percentage));
        final top = taskTimeDistribution.first;

        // Convert minutes into percentage relative to total
        double pct = (top.percentage / totalMinutes) * 100;

        feedback.add(
          FeedbackEntry(
            sentiment: "neutral",
            message:
                "${top.subName} received the most focus (${pct.toStringAsFixed(0)}% of your time).",
            category: "Tasks",
          ),
        );
      }
    }

    return feedback;
  }

  // ---------- ACTIVITY FEEDBACK ----------
  static List<FeedbackEntry> generateActivityFeedback({
    required List<ActivitiesTimeSpent> activitiesTimeSpent,
    required List<ActivitiesDone> activitiesDone,
    required List<FinishedTask> taskFinished,
    required int totalActivities,
    double? previousTotalMinutes,
  }) {
    List<FeedbackEntry> feedback = [];

    // ---------- Activity Completion Rate ----------
    if (totalActivities > 0) {
      int finished = activitiesDone.isNotEmpty
          ? activitiesDone.first.totalActivityDone
          : 0;
      double rate = (finished / totalActivities) * 100;

      if (rate >= 80) {
        feedback.add(FeedbackEntry(
          sentiment: "positive",
          message:
              "Great job finishing ${rate.toStringAsFixed(0)}% of your activities.",
          category: "Activities",
        ));
      } else if (rate >= 50) {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "You completed about half of your activities (${rate.toStringAsFixed(0)}%).",
          category: "Activities",
        ));
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "negative",
          message:
              "Low completion rate: only ${rate.toStringAsFixed(0)}% of activities done.",
          category: "Activities",
        ));
      }
    }

    // ---------- Time Spent Trend ----------
    if (activitiesTimeSpent.isNotEmpty) {
      double currentTotal = activitiesTimeSpent.fold(
        0,
        (sum, item) => sum + item.minutes,
      );

      if (previousTotalMinutes != null && previousTotalMinutes > 0) {
        double percentChange =
            ((currentTotal - previousTotalMinutes) / previousTotalMinutes) *
                100;

        if (percentChange >= 20) {
          feedback.add(FeedbackEntry(
            sentiment:
                "negative", // spending more time on activities could harm studies
            message:
                "Activity time increased by ${percentChange.toStringAsFixed(0)}%. Be mindful not to let it cut into academics.",
            category: "Activities",
          ));
        } else if (percentChange <= -20) {
          feedback.add(FeedbackEntry(
            sentiment: "positive", // less activity time = more space for tasks
            message:
                "Activity time dropped by ${percentChange.abs().toStringAsFixed(0)}%. That leaves more room for academics.",
            category: "Activities",
          ));
        } else {
          feedback.add(FeedbackEntry(
            sentiment: "neutral",
            message:
                "Activity time stayed steady with a ${percentChange.toStringAsFixed(0)}% change.",
            category: "Activities",
          ));
        }
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "You logged ${_fmtMinutes(currentTotal)} on activities. No previous data to compare.",
          category: "Activities",
        ));
      }
    }

    // ---------- Activities vs. Tasks Balance ----------
    int completedActivities =
        activitiesDone.isNotEmpty ? activitiesDone.first.totalActivityDone : 0;

    int completedTasks =
        taskFinished.isNotEmpty ? taskFinished.first.totalTaskFinished : 0;

    if (completedTasks > 0 || completedActivities > 0) {
      if (completedActivities > completedTasks * 1.2) {
        feedback.add(FeedbackEntry(
          sentiment: "negative",
          message:
              "You did $completedActivities activities vs. $completedTasks tasks — activities outweigh tasks. Try to shift focus back to academics.",
          category: "Activities",
        ));
      } else if (completedActivities < completedTasks * 0.8) {
        feedback.add(FeedbackEntry(
          sentiment: "positive",
          message:
              "You did $completedActivities activities vs. $completedTasks tasks — a healthy academic priority.",
          category: "Activities",
        ));
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "You did $completedActivities activities and $completedTasks tasks — fairly balanced this period.",
          category: "Activities",
        ));
      }
    }

    return feedback;
  }

  // ---------- SLEEP FEEDBACK ----------
  static List<FeedbackEntry> generateSleepFeedback({
    required List<SleepDuration> sleepDuration,
    required List<SleepRegularity> sleepRegularity,
    double? previousTotalMinutes,
  }) {
    List<FeedbackEntry> feedback = [];

    if (sleepDuration.isNotEmpty) {
      // --- Current totals ---
      double currentTotal = sleepDuration.fold(
        0,
        (sum, item) => sum + (item.hours * 60),
      );
      double avgSleep = currentTotal / sleepDuration.length;

      // ---------- Sleep Duration Trend ----------
      if (previousTotalMinutes != null && previousTotalMinutes > 0) {
        double percentChange =
            ((currentTotal - previousTotalMinutes) / previousTotalMinutes) *
                100;

        if (percentChange >= 20) {
          feedback.add(FeedbackEntry(
            sentiment: "positive",
            message:
                "Sleep time increased by ${percentChange.toStringAsFixed(0)}%. Great recovery!",
            category: "Sleep",
          ));
        } else if (percentChange <= -20) {
          feedback.add(FeedbackEntry(
            sentiment: "negative",
            message:
                "Sleep time dropped by ${percentChange.abs().toStringAsFixed(0)}%. Try to rest more.",
            category: "Sleep",
          ));
        } else {
          feedback.add(FeedbackEntry(
            sentiment: "neutral",
            message:
                "Sleep time stayed steady with a ${percentChange.toStringAsFixed(0)}% change.",
            category: "Sleep",
          ));
        }
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "You slept a total of ${_fmtMinutes(currentTotal)}. No previous data to compare.",
          category: "Sleep",
        ));
      }

      // ---------- Average vs Recommended ----------
      if (avgSleep < 330) {
        // < 5.5 hrs
        feedback.add(FeedbackEntry(
          sentiment: "negative",
          message:
              "Average sleep ${(avgSleep / 60).toStringAsFixed(1)} hrs — well below healthy levels. Try to get more rest.",
          category: "Sleep",
        ));
      } else if (avgSleep < 420) {
        // 5.5–7 hrs
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "Average sleep ${(avgSleep / 60).toStringAsFixed(1)} hrs — a bit under the 7–9 hr range.",
          category: "Sleep",
        ));
      } else if (avgSleep <= 540) {
        // 7–9 hrs
        feedback.add(FeedbackEntry(
          sentiment: "positive",
          message:
              "Average sleep ${(avgSleep / 60).toStringAsFixed(1)} hrs — right in the healthy range!",
          category: "Sleep",
        ));
      } else {
        // > 9 hrs
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "Average sleep ${(avgSleep / 60).toStringAsFixed(1)} hrs — above the usual 7–9 hrs.",
          category: "Sleep",
        ));
      }
    }

    // ---------- Sleep Regularity ----------
    if (sleepRegularity.length > 1) {
      List<int> bedtimes = sleepRegularity.map((log) => log.startTime).toList();

      double mean = bedtimes.reduce((a, b) => a + b) / bedtimes.length;
      double variance = bedtimes
              .map((bt) => (bt - mean) * (bt - mean))
              .reduce((a, b) => a + b) /
          bedtimes.length;
      double stdDev = sqrt(variance);

      if (stdDev <= 60) {
        feedback.add(FeedbackEntry(
          sentiment: "positive",
          message: "Consistent sleep schedule. Bedtimes varied less than 1 hr.",
          category: "Sleep",
        ));
      } else if (stdDev <= 120) {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "Sleep schedule somewhat regular. Bedtimes varied about 1–2 hrs.",
          category: "Sleep",
        ));
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "negative",
          message:
              "Irregular sleep schedule. Bedtimes varied more than 2 hrs. Try a more consistent routine.",
          category: "Sleep",
        ));
      }
    }

    return feedback;
  }

  // ---------- GOAL FEEDBACK ----------
  static List<FeedbackEntry> generateGoalFeedback({
    required List<GoalTimeSpent> goalTimeSpent,
    required List<GoalTimeDistribution> goalTimeDistribution,
    required List<GoalCompletionCount> goalCompletionCount,
    double? previousTotalMinutes,
  }) {
    List<FeedbackEntry> feedback = [];

    // ---------- Overall Completion Rate ----------
    int totalCompleted =
        goalCompletionCount.fold(0, (sum, g) => sum + g.completedCount);
    int totalFailed =
        goalCompletionCount.fold(0, (sum, g) => sum + g.failedCount);
    int totalAttempts = totalCompleted + totalFailed;

    if (totalAttempts > 0) {
      double rate = (totalCompleted / totalAttempts) * 100;

      if (rate >= 80) {
        feedback.add(FeedbackEntry(
          sentiment: "positive",
          message:
              "Strong progress — ${rate.toStringAsFixed(0)}% of goals completed.",
          category: "Goals",
        ));
      } else if (rate >= 50) {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "You’re at ${rate.toStringAsFixed(0)}% of goals completed. Keep pushing.",
          category: "Goals",
        ));
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "negative",
          message:
              "Only ${rate.toStringAsFixed(0)}% of goals completed. Try smaller, consistent steps.",
          category: "Goals",
        ));
      }
    }

    // ---------- Time Spent Trend ----------
    if (goalTimeSpent.isNotEmpty) {
      double currentTotal = goalTimeSpent.fold(
        0,
        (sum, item) => sum + item.minutes,
      );

      if (previousTotalMinutes != null && previousTotalMinutes > 0) {
        double percentChange =
            ((currentTotal - previousTotalMinutes) / previousTotalMinutes) *
                100;

        if (percentChange >= 20) {
          feedback.add(
            FeedbackEntry(
              sentiment: "positive",
              message:
                  "Goal time increased by ${percentChange.toStringAsFixed(0)}%. Great consistency boost!",
              category: "Goals",
            ),
          );
        } else if (percentChange <= -20) {
          feedback.add(
            FeedbackEntry(
              sentiment: "negative",
              message:
                  "Goal time dropped by ${percentChange.abs().toStringAsFixed(0)}%. Try to stay consistent.",
              category: "Goals",
            ),
          );
        } else {
          feedback.add(
            FeedbackEntry(
              sentiment: "neutral",
              message:
                  "Goal time stayed steady with a ${percentChange.toStringAsFixed(0)}% change.",
              category: "Goals",
            ),
          );
        }
      } else {
        feedback.add(
          FeedbackEntry(
            sentiment: "neutral",
            message:
                "You logged ${_fmtMinutes(currentTotal)} on goals. No previous data to compare.",
            category: "Goals",
          ),
        );
      }
    }

    // ---------- Time Distribution ----------
    if (goalTimeDistribution.isNotEmpty) {
      // Get the total minutes spent across all subjects
      double totalMinutes = goalTimeDistribution.fold(
        0,
        (sum, item) => sum + item.percentage,
      );

      if (totalMinutes > 0) {
        // Sort so the subject with the most time comes first
        goalTimeDistribution
            .sort((a, b) => b.percentage.compareTo(a.percentage));
        final top = goalTimeDistribution.first;

        // Convert minutes into percentage relative to total
        double pct = (top.percentage / totalMinutes) * 100;

        feedback.add(
          FeedbackEntry(
            sentiment: "neutral",
            message:
                "${top.goalType} goals took the most focus (${pct.toStringAsFixed(0)}% of your time).",
            category: "Goals",
          ),
        );
      }
    }

    return feedback;
  }

  // ---------- EVENT FEEDBACK ----------
  static List<FeedbackEntry> generateEventFeedback({
    required List<EventAttendancecSummary> eventAttendanceSummary,
    required List<EventTypeDistribution> eventTypeDistribution,
    required List<EventAttendanceDistribution> eventAttendanceDistribution,
    int? previousAttendedCount,
    int? previousTotalEvents,
  }) {
    List<FeedbackEntry> feedback = [];

    // ---------- Attendance Rate ----------
    int attended = eventAttendanceSummary
        .where((e) => e.attendance == "Attended")
        .fold(0, (sum, e) => sum + e.attendanceCount);
    int totalEvents =
        eventAttendanceSummary.fold(0, (sum, e) => sum + e.attendanceCount);

    if (totalEvents > 0) {
      double rate = (attended / totalEvents) * 100;

      if (rate >= 80) {
        feedback.add(FeedbackEntry(
          sentiment: "positive",
          message:
              "Great job — you attended ${rate.toStringAsFixed(0)}% of your events.",
          category: "Events",
        ));
      } else if (rate >= 50) {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "You attended about ${rate.toStringAsFixed(0)}% of your events. Some were missed.",
          category: "Events",
        ));
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "negative",
          message:
              "Only ${rate.toStringAsFixed(0)}% of events were attended. Consider reviewing your commitments.",
          category: "Events",
        ));
      }
    }

    // ---------- Attendance Trend ----------
    if (previousAttendedCount != null &&
        previousTotalEvents != null &&
        previousTotalEvents > 0) {
      double prevRate = (previousAttendedCount / previousTotalEvents) * 100;
      double currRate = totalEvents > 0 ? (attended / totalEvents) * 100 : 0;
      double diff = currRate - prevRate;

      if (diff >= 10) {
        feedback.add(FeedbackEntry(
          sentiment: "positive",
          message:
              "Event attendance improved by ${diff.toStringAsFixed(0)}% compared to last period.",
          category: "Events",
        ));
      } else if (diff <= -10) {
        feedback.add(FeedbackEntry(
          sentiment: "negative",
          message:
              "Attendance dropped by ${diff.abs().toStringAsFixed(0)}% compared to last period.",
          category: "Events",
        ));
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "Attendance stayed consistent (${diff.toStringAsFixed(0)}% change).",
          category: "Events",
        ));
      }
    } else if (totalEvents > 0) {
      feedback.add(FeedbackEntry(
        sentiment: "neutral",
        message:
            "You attended $attended of $totalEvents events. No previous data to compare.",
        category: "Events",
      ));
    }

    // ---------- Consistency / Balance ----------
    if (eventTypeDistribution.isNotEmpty) {
      eventTypeDistribution
          .sort((a, b) => b.attendanceCount.compareTo(a.attendanceCount));
      final top = eventTypeDistribution.first;
      int totalEvents = eventTypeDistribution.fold(
        0,
        (sum, item) => sum + item.attendanceCount,
      );
      double pct = (top.attendanceCount / totalEvents) * 100;

      if (pct >= 70) {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "Most of your events were ${top.eventType} (${pct.toStringAsFixed(0)}%). Try balancing with other types.",
          category: "Events",
        ));
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message: "Good balance between event types this period.",
          category: "Events",
        ));
      }
    }

    return feedback;
  }

  // ---------- CLASS SCHEDULE FEEDBACK ----------
  static List<FeedbackEntry> generateClassScheduleFeedback({
    required List<ClassAttendanceSummary> classAttendanceSummary,
    required List<ClassAttendanceDistribution> classAttendanceDistribution,
    int? previousAttendedCount,
    int? previousTotalClasses,
  }) {
    List<FeedbackEntry> feedback = [];

    // ---------- Attendance Rate ----------
    int attended = classAttendanceSummary
        .where((e) => e.category == "Attended")
        .fold(0, (sum, e) => sum + e.count);
    int totalClasses =
        classAttendanceSummary.fold(0, (sum, e) => sum + e.count);

    if (totalClasses > 0) {
      double rate = (attended / totalClasses) * 100;

      if (rate >= 80) {
        feedback.add(FeedbackEntry(
          sentiment: "positive",
          message:
              "Great consistency — you attended ${rate.toStringAsFixed(0)}% of your classes.",
          category: "Class Schedules",
        ));
      } else if (rate >= 60) {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "You attended about ${rate.toStringAsFixed(0)}% of your classes — room for improvement.",
          category: "Class Schedules",
        ));
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "negative",
          message:
              "Only ${rate.toStringAsFixed(0)}% of classes attended. Try improving participation.",
          category: "Class Schedules",
        ));
      }
    }

    // ---------- Attendance Trend ----------
    if (previousAttendedCount != null &&
        previousTotalClasses != null &&
        previousTotalClasses > 0) {
      double prevRate = (previousAttendedCount / previousTotalClasses) * 100;
      double currRate = totalClasses > 0 ? (attended / totalClasses) * 100 : 0;
      double diff = currRate - prevRate;

      if (diff >= 10) {
        feedback.add(FeedbackEntry(
          sentiment: "positive",
          message:
              "Class attendance improved by ${diff.toStringAsFixed(0)}% compared to last period.",
          category: "Class Schedules",
        ));
      } else if (diff <= -10) {
        feedback.add(FeedbackEntry(
          sentiment: "negative",
          message:
              "Attendance dropped by ${diff.abs().toStringAsFixed(0)}% compared to last period.",
          category: "Class Schedules",
        ));
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "Attendance stayed consistent (${diff.toStringAsFixed(0)}% change).",
          category: "Class Schedules",
        ));
      }
    } else if (totalClasses > 0) {
      feedback.add(FeedbackEntry(
        sentiment: "neutral",
        message:
            "You attended $attended of $totalClasses classes. No previous data to compare.",
        category: "Class Schedules",
      ));
    }

    // ---------- Subject Weak Spot ----------
    if (classAttendanceDistribution.isNotEmpty) {
      // Sort by attendance rate ascending
      classAttendanceDistribution.sort((a, b) {
        double rateA = a.attended / (a.attended + a.excused + a.didNotAttend);
        double rateB = b.attended / (b.attended + b.excused + b.didNotAttend);
        return rateA.compareTo(rateB);
      });

      final weakest = classAttendanceDistribution.first;
      int totalForWeakest =
          weakest.attended + weakest.excused + weakest.didNotAttend;
      double weakestRate =
          totalForWeakest > 0 ? (weakest.attended / totalForWeakest) * 100 : 0;

      if (weakestRate >= 80) {
        feedback.add(FeedbackEntry(
          sentiment: "positive",
          message:
              "Strong consistency across all subjects — attendance above 80%.",
          category: "Class Schedules",
        ));
      } else if (weakestRate >= 60) {
        feedback.add(FeedbackEntry(
          sentiment: "neutral",
          message:
              "Your lowest attendance is in ${weakest.subject} (${weakestRate.toStringAsFixed(0)}%).",
          category: "Class Schedules",
        ));
      } else {
        feedback.add(FeedbackEntry(
          sentiment: "negative",
          message:
              "Attendance is low in ${weakest.subject} (${weakestRate.toStringAsFixed(0)}%). This may affect performance.",
          category: "Class Schedules",
        ));
      }
    }

    return feedback;
  }

  static String _fmtMinutes(double minutes) {
    if (minutes < 60) return "${minutes.toStringAsFixed(0)} mins";
    double hours = minutes / 60;
    return "${hours.toStringAsFixed(1)} hrs";
  }
}
