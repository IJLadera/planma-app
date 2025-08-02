import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:planma_app/features/authentication/presentation/providers/user_provider.dart';
import 'package:planma_app/Providers/userprof_provider.dart';
import 'package:planma_app/features/authentication/presentation/pages/log_in_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planma_app/user_preferences/sleep_wake.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers for form fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // For toggling password visibility
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isLoading = false;

  // Global key for the form
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose controllers when not in use
    firstNameController.dispose();
    lastNameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Show signing up message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Signing up...",
              style: GoogleFonts.openSans(fontSize: 14),
            ),
          ),
        );

        // Get the UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Call the register method from UserProvider
        final success = await userProvider.register(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          username: userNameController.text,
          email: emailController.text,
          password: passwordController.text,
        );

        // Remove the signing up message
        ScaffoldMessenger.of(context).clearSnackBars();

        if (success) {
          // Sign-up successful
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Account created successfully!",
                style: GoogleFonts.openSans(fontSize: 14),
              ),
            ),
          );

          // Initialize user profile provider
          await context.read<UserProfileProvider>().init();

          // Navigate to sleep/wake setup screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SleepWakeSetupScreen(),
            ),
          );
        } else {
          // Sign-up failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed to create account. Please try again.",
                style: GoogleFonts.openSans(fontSize: 14),
              ),
            ),
          );
        }
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${e.toString()}",
              style: GoogleFonts.openSans(fontSize: 14),
            ),
          ),
        );
      } finally {
        // Reset loading state
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? validatePassword(String? value) {
    final originalPassword = passwordController.text;

    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    // Uncomment below if you want uppercase requirement
    // if (!RegExp(r'[A-Z]').hasMatch(value)) {
    //   return 'Password must contain at least one uppercase letter';
    // }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    final originalPassword = passwordController.text;

    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Color(0xFFFFFFFF),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sign Up text below AppBar
                  Text(
                    'Sign Up',
                    style: GoogleFonts.openSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173F70),
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing between title and form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            labelStyle: GoogleFonts.openSans(),
                            labelText: 'First Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your first name'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            labelStyle: GoogleFonts.openSans(),
                            labelText: 'Last Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your last name'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: userNameController,
                          decoration: InputDecoration(
                            labelStyle: GoogleFonts.openSans(),
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your username'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelStyle: GoogleFonts.openSans(),
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelStyle: GoogleFonts.openSans(),
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: validatePassword,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelStyle: GoogleFonts.openSans(),
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: validateConfirmPassword,
                        ),
                        const SizedBox(height: 50),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    _signUp(context);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width *
                                  0.25, // 25% of screen width
                              vertical: MediaQuery.of(context).size.height *
                                  0.02, // 2% of screen height
                            ),
                            backgroundColor: const Color(0xFF173F70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: GoogleFonts.openSans(
                              color: Color(0xFF173F70),
                            ),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173F70),
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LogInPage()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
