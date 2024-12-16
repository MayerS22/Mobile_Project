import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';
import 'AdminDashboardScreen.dart';
import 'SignUpScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  bool _isPasswordVisible = false;
  bool _rememberMe = false; // Remember me flag

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials(); // Load saved credentials on screen load
  }

  // Load credentials from SharedPreferences
  _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    bool? rememberMe = prefs.getBool('rememberMe') ?? false;
    if (rememberMe) {
      String? savedEmail = prefs.getString('email');
      String? savedPassword = prefs.getString('password');
      if (savedEmail != null && savedPassword != null) {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
        _rememberMe = true;
      }
    }
    setState(() {});
  }

  // Save credentials in SharedPreferences
  _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      prefs.setBool('rememberMe', true);
      prefs.setString('email', emailController.text.trim());
      prefs.setString('password', passwordController.text.trim());
    } else {
      prefs.setBool('rememberMe', false);
      prefs.remove('email');
      prefs.remove('password');
    }
  }

  // Sign in logic
  void signin() async {
    if (formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        // Sign in with Firebase Auth
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Save credentials if "Remember Me" is selected
        _saveCredentials();

        // Check if the email belongs to an admin
        if (emailController.text.trim() == 'admin1@gmail.com' || emailController.text.trim() == 'admin2@gmail.com') {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
          );
        } else {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);

        String message = '';
        switch (e.code) {
          case 'user-not-found':
            message = 'No user found for this email.';
            break;
          case 'wrong-password':
            message = 'Incorrect password.';
            break;
          default:
            message = 'An error occurred. Please try again.';
        }

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
              ],
            );
          },
        );
      }
    }
  }

  // Forgot password logic
  Future<void> _forgotPassword() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Please enter your email address."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
            ],
          );
        },
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Password Reset"),
            content: const Text("Password reset email sent! Check your inbox."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      String message = e.code == 'user-not-found'
          ? 'No user found for this email address.'
          : 'An error occurred. Please try again.';

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xFF22223B),
                Color(0xFF4A4E69),
                Color(0xFF9A8C98),
                Color(0xFFC9ADA7),
                Color(0xFFF2E9E4),
              ]),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Welcome Back\nSign in!',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFFF2E9E4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Color(0xFFF2E9E4),
              ),
              height: MediaQuery.of(context).size.height - 200,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        // User Icon
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: const Color(0xFF4A4E69),
                          child: const Icon(
                            Icons.person_outline,
                            size: 100,
                            color: Color(0xFFF2E9E4),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email must not be empty';
                            }
                            if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          controller: emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email, color: Color(0xFF22223B)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            hintText: 'Enter Email Address',
                            labelText: 'Email Address',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password must not be empty';
                            }
                            return null;
                          },
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFF22223B)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            hintText: 'Enter Password',
                            labelText: 'Password',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Remember Me Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (bool? value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                            ),
                            const Text("Remember Me"),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Sign In Button
                        Container(
                          height: 45,
                          width: 200,
                          child: ElevatedButton(
                            onPressed: signin,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor: const Color(0xFF22223B),
                            ),
                            child: const Text(
                              "Sign In",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sign Up and Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9A8C98)),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Color(0xFF22223B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
