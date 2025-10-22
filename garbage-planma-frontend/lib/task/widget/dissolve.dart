import 'package:flutter/material.dart';

void _showDissolvableModal(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (BuildContext context) {
      return DissolvableModal(message: message);
    },
  );
}

class DissolvableModal extends StatefulWidget {
  final String message;

  const DissolvableModal({Key? key, required this.message}) : super(key: key);

  @override
  _DissolvableModalState createState() => _DissolvableModalState();
}

class _DissolvableModalState extends State<DissolvableModal> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation; // Specify the type here

  @override
  void initState() {
    super.initState();

    // Set up fade-out animation
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Duration for modal to dissolve
      vsync: this,
    );

    // Create fade animation with the correct type (double)
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.of(context).pop(); // Close the dialog after fade-out
        }
      });

    _controller.forward(); // Start fade-out animation
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Transparent background to show fade effect
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Material(
            color: Colors.black.withOpacity(0.7), // Dark background with transparency
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                widget.message,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
