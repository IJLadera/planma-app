import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:planma_app/Providers/user_provider.dart';
import 'package:planma_app/authentication/forgot_password.dart';
import 'package:planma_app/authentication/sign_up.dart';
import 'package:planma_app/core/dashboard.dart';
import 'package:planma_app/Front%20&%20back%20end%20connections/login_auth.dart';
import 'package:planma_app/main.dart';
import 'package:provider/provider.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();


  bool obscurePassword = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
  if (_formKey.currentState!.validate()) {
    final email = emailController.text;
    final password = passwordController.text;
    
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email and password cannot be empty")),
      );
      return; // Early exit if fields are empty
    }

    ("Logging in with email: $email and password: $password");

    // Proceed with the login logic
    final authLogin = AuthLogin();
    // print(email);
    // print(password);
    final response = await authLogin.logIn(
      email: email,
      password: password,
    );
    if (response != null && response["error"] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome User")),
      );
      context.read<UserProvider>().init(
        userName: email,
        accessToken: response['access'],
        refreshToken: response['refresh']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(),
        ),
      );
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wrong Credentials")),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
          key: _formKey,
          child: Center(
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
            controller: emailController,
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
            onPressed: () async {              
              if (_formKey.currentState!.validate()) {
                          // If validation is successful, navigate to LogIn screen
                 await _login(context);
              
              }
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
                    color: Color(0xFF173F70),
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
    ))),);
  }
}
