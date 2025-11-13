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
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       "Signing up...",
        //       style: GoogleFonts.openSans(fontSize: 14),
        //     ),
        //   ),
        // );

        // Get the UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Call the register method from UserProvider
        final success = await userProvider.register(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          username: userNameController.text,
          email: emailController.text,
          password: passwordController.text,
          rePassword: confirmPasswordController.text,
        );

        // Remove the signing up message
        ScaffoldMessenger.of(context).clearSnackBars();

        if (success) {
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

  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    if (!RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ\s'-]+$").hasMatch(value)) {
      return 'Enter a valid first name';
    }
    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    if (!RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ\s'-]+$").hasMatch(value)) {
      return 'Enter a valid last name';
    }
    if (value.trim().length < 2) {
      return 'Last name must be at least 2 characters';
    }
    return null;
  }

  Future<String?> validateEmail(
      String? value, UserProvider userProvider) async {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    // Check if email exists in DB
    final isTaken = await userProvider.isEmailTaken(value.trim());
    if (isTaken) {
      return 'This email is already registered';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Include at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Include at least one special character';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173F70),
                    ),
                  ),
                  const SizedBox(height: 25), // Spacing between title and form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextFormField(
                          controller: firstNameController,
                          labelText: 'First Name',
                          icon: Icons.person,
                          validator: validateFirstName,
                        ),
                        const SizedBox(height: 15),
                        _buildTextFormField(
                          controller: lastNameController,
                          labelText: 'Last Name',
                          icon: Icons.person_outline,
                          validator: validateLastName,
                        ),
                        const SizedBox(height: 15),
                        _buildTextFormField(
                          controller: emailController,
                          labelText: 'Email',
                          icon: Icons.email,
                          validator: (value) =>
                              null, // We’ll handle async validation below
                        ),
                        const SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      final userProvider =
                                          Provider.of<UserProvider>(context,
                                              listen: false);
                                      final emailError = await validateEmail(
                                          emailController.text, userProvider);
                                      if (emailError != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(emailError)),
                                        );
                                        return; // Stop if email already exists
                                      }
                                      _signUp(context);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF173F70),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 100),
                            ),
                            child: _isLoading
                                ? const SizedBox(
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
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.openSans(),
        prefixIcon: Icon(icon, color: const Color(0xFF173F70)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      validator: validator,
      style: GoogleFonts.openSans(),
    );
  }
}
