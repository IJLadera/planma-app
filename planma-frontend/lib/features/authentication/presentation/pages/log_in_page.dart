import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:planma_app/features/authentication/presentation/providers/user_provider.dart';
import 'package:planma_app/Providers/userprof_provider.dart';
import 'package:planma_app/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:planma_app/features/authentication/presentation/pages/sign_up_page.dart';
import 'package:planma_app/core/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text;
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Email and password cannot be empty",
                  style: GoogleFonts.openSans())),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Use the UserProvider for login
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final success = await userProvider.login(email, password);

        if (success) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //       content: Text("Welcome User", style: GoogleFonts.openSans())),
          // );

          // Initialize the user profile provider
          await context.read<UserProfileProvider>().init();

          // Navigate to Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text("Wrong Credentials", style: GoogleFonts.openSans())),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Login failed: ${e.toString()}",
                  style: GoogleFonts.openSans())),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Ensures the screen adjusts for the keyboard
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 90),
                      Container(
                        height: constraints.maxHeight *
                            0.25, // 25% of screen height
                        alignment: Alignment.center,
                        child: Text(
                          'Login to your account',
                          style: GoogleFonts.openSans(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF173F70),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextFormField(
                              controller: emailController,
                              labelText: 'Email',
                              icon: Icons.person,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter your email'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            _buildTextFormField(
                              controller: passwordController,
                              labelText: 'Password',
                              icon: Icons.lock,
                              obscureText: obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF173F70),
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter your password'
                                  : null,
                            ),
                            SizedBox(height: 15),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.openSans(
                                    fontSize: 14,
                                    color: const Color(0xFF173F70),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              height:
                                  50, // Match the height of the TextFormField
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF173F70),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12), // Match TextFormField's border radius
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          12), // Match horizontal padding
                                ),
                                child: _isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        'Login',
                                        style: GoogleFonts.openSans(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: GoogleFonts.openSans(
                          color: Color(0xFF173F70),
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: GoogleFonts.openSans(
                              color: const Color(0xFF173F70),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpPage(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
