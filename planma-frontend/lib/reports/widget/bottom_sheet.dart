import 'package:flutter/material.dart';

class BottomSheetWidget extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String initialSelection;

  const BottomSheetWidget({
    Key? key,
    required this.onCategorySelected,
    required this.initialSelection,
  }) : super(key: key);

  // Static method to show the BottomSheet
  static void show(BuildContext context,
      {required Function(String) onCategorySelected,
      required String initialSelection}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return BottomSheetWidget(
            onCategorySelected: onCategorySelected,
            initialSelection: initialSelection);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                "Categories",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _buildRadioTile(
              title: "Task",
              value: "Task",
              onChanged: (value) {
                onCategorySelected(
                    value!); // Pass the selected category to the callback
                Navigator.pop(context); // Close the bottom sheet
              },
            ),
            _buildRadioTile(
              title: "Event",
              value: "Event",
              onChanged: (value) {
                onCategorySelected(value!);
                Navigator.pop(context);
              },
            ),
            _buildRadioTile(
              title: "Class Schedules",
              value: "Class Schedules",
              onChanged: (value) {
                onCategorySelected(value!);
                Navigator.pop(context);
              },
            ),
            _buildRadioTile(
              title: "Activities",
              value: "Activities",
              onChanged: (value) {
                onCategorySelected(value!);
                Navigator.pop(context);
              },
            ),
            _buildRadioTile(
              title: "Goals",
              value: "Goals",
              onChanged: (value) {
                onCategorySelected(value!);
                Navigator.pop(context);
              },
            ),
            _buildRadioTile(
              title: "Sleep",
              value: "Sleep",
              onChanged: (value) {
                onCategorySelected(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text(title),
          value: value,
          groupValue: initialSelection,
          onChanged: onChanged,
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        if (title != "Sleep") // No divider below the last option
          Divider(
            thickness: 1,
            color: Colors.grey.shade300,
          ),
      ],
    );
  }
}
