import 'package:flutter/material.dart';

class TaskCard extends StatefulWidget {
  final String taskName;
  final String subject;
  final String duration;

  const TaskCard({super.key, 
    required this.taskName,
    required this.subject,
    required this.duration,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool isChecked = false;

  void toggleCheckbox() {
    setState(() {
      isChecked = !isChecked;
    });
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red; // High priority - red
      case 'Medium':
        return Colors.orange; // Medium priority - orange
      case 'Low':
        return Colors.green; // Low priority - green
      default:
        return Colors.grey; // Default color for no priority
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: toggleCheckbox,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isChecked ? Colors.green : Colors.white,
                    border: Border.all(
                        color: Colors.black26), // Border for visual clarity
                  ),
                  child: isChecked
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.taskName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${widget.subject} (${widget.duration})'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
