import 'package:flutter/material.dart';
import 'package:planma_app/task/by_date.dart';
import 'package:planma_app/task/by_subject.dart';

class FilterDialog extends StatelessWidget {
  final Function(String) onFilterSelected;

  FilterDialog({required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('By Date'),
            onTap: () {
              // Call the function to notify the parent widget
              onFilterSelected('By Date');
              // Navigate to the ByDate screen and close the dialog
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ByDate()),
              );
            },
          ),
          ListTile(
            title: Text('By Subject'),
            onTap: () {
              // Call the function to notify the parent widget
              onFilterSelected('By Subject');
              // Navigate to the BySubject screen and close the dialog
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BySubject()),
              );
            },
          ),
        ],
      ),
    );
  }
}
