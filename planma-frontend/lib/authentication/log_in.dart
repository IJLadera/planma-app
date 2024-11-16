import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:planma_app/authentication/forgot_password.dart';
import 'package:planma_app/authentication/sign_up.dart';
import 'package:planma_app/core/dashboard.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Perform login logic (e.g., API call)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logging in...")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 40.0), // Increased horizontal padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Login to your account',
            style: TextStyle(
              fontSize: 30, // Increased font size
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 30), // Increased space between elements
          TextFormField(
            controller: userNameController,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: const Icon(Icons.person, size: 30), // Increased icon size
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), // More rounded borders
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter your username' : null,
            style:
                const TextStyle(fontSize: 20), // Increased font size for input text
          ),
          const SizedBox(height: 20), // Increased space
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock, size: 30), // Increased icon size
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), // More rounded borders
              ),
              suffixIcon: IconButton(
                icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                    size: 30), // Increased icon size
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter your password' : null,
            style:
                const TextStyle(fontSize: 20), // Increased font size for input text
          ),
          const SizedBox(height: 20), // Increased space
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPassword()),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(fontSize: 18), // Increased font size
              ),
            ),
          ),
          const SizedBox(height: 30), // Increased space
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Dashboard(username: userNameController.text)),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 150, vertical: 20), // Increased button padding
              backgroundColor: const Color(0xFF173F70),
              textStyle:
                  const TextStyle(fontSize: 20), // Increased text size in the button
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 20, // Increased font size
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30), // Increased space
          RichText(
            text: TextSpan(
              text: 'Already have an account? ',
              style: const TextStyle(
                  color: Colors.black, fontSize: 18), // Increased font size
              children: <TextSpan>[
                TextSpan(
                  text: 'Sign Up',
                  style: TextStyle(
                    color: Colors.blue[900],
                    decoration: TextDecoration.underline,
                    fontSize: 18, // Increased font size
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUp()),
                      );
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    )));
  }
}
