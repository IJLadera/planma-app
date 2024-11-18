import 'package:flutter/material.dart';

class GoalDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goal'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Edit action
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Delete action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDetailRow('Name:', 'Practice Piano'),
            buildDetailRow('Description:', 'Improve Piano Skills'),
            buildDetailRow('Timeframe:', 'Weekly'),
            buildDetailRow('Target Hour:', '10 hours'),
            buildDetailRow('Type:', 'Personal'),
            buildDetailRow('Semester:', '1st Sem - 4th Year'),
            SizedBox(height: 24),
            Text(
              'Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text('Goal Session 1'),
              subtitle: Text('Date \n(Time Period)'),
              isThreeLine: true,
              tileColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add session action
              },
              child: Text('Add Session'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
