import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';  // For date formatting
import 'SignInScreen.dart'; // Make sure to import the SignInScreen
import '../Models/UserProfile.dart'; // Make sure to import the UserProfile model
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  TextEditingController confirmpasscontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController birthdaycontroller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF22223B),
                  Color(0xFF4A4E69),
                  Color(0xFF9A8C98),
                  Color(0xFFC9ADA7),
                  Color(0xFFF2E9E4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Create Your\nAccount',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Form Container
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Color(0xFFF2E9E4),
              ),
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: namecontroller,
                          label: "Full Name",
                          hint: "Enter your name",
                          icon: Icons.person,
                          validator: (value) {
                            if (value!.isEmpty) return "Name must not be null";
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: emailcontroller,
                          label: "Email Address",
                          hint: "Enter your email",
                          icon: Icons.email,
                          validator: (value) {
                            if (value!.isEmpty) return "Email must not be null";
                            if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                                .hasMatch(value)) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Add Birthday Field
                        _buildTextField(
                          controller: birthdaycontroller,
                          label: "Birthday",
                          hint: "Enter your birthday (DD-MM-YYYY)",
                          icon: Icons.calendar_today,
                          validator: (value) {
                            if (value!.isEmpty) return "Birthday must not be null";
                            try {
                              DateFormat('dd-MM-yyyy').parse(value);
                            } catch (_) {
                              return "Please enter a valid date in DD-MM-YYYY format";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: passcontroller,
                          label: "Password",
                          hint: "Enter your password",
                          icon: Icons.lock,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) return "Password must not be null";
                            if (value.length < 6) return "Password must be at least 6 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: confirmpasscontroller,
                          label: "Confirm Password",
                          hint: "Re-enter your password",
                          icon: Icons.lock,
                          isPassword: true,
                          isPasswordVisible: _isConfirmPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) return "Please confirm your password";
                            if (value != passcontroller.text) return "Passwords do not match";
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 45,
                          width: 200,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: const Color(0xFF22223B),
                            ),
                            onPressed: signup,
                            child: const Text(
                              "Register Account",
                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInScreen()),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(color: Color(0xFF22223B), fontWeight: FontWeight.bold),
                              ),
                            ]),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    void Function()? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF22223B)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF22223B),
          ),
          onPressed: onToggleVisibility,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Color(0xFF22223B)),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  void signup() async {
    if (formKey.currentState!.validate()) {
      // Show loading dialog
      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        // Create user with Firebase
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailcontroller.text.trim(),
          password: passcontroller.text.trim(),
        );

        // Get the user UID
        String uid = userCredential.user!.uid;

        // Create UserProfile object
        final userProfile = UserProfile(
          name: namecontroller.text,
          email: emailcontroller.text,
          birthday: DateFormat('dd-MM-yyyy').parse(birthdaycontroller.text),
        );

        // Save userProfile in Firestore
        await saveUserProfile(uid, userProfile);

        // Dismiss the loading dialog
        Navigator.pop(context);

        // Navigate to SignInScreen after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        });
      } on FirebaseAuthException catch (e) {
        // Close the loading dialog
        Navigator.pop(context);

        String message = '';
        switch (e.code) {
          case 'email-already-in-use':
            message = "This email is already in use. Please use a different email.";
            break;
          case 'weak-password':
            message = "Password is too weak.";
            break;
          default:
            message = "An error occurred. Please try again.";
        }

        // Show error message using a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }


  // Method to save UserProfile in Firestore (or any other backend)


  Future<void> saveUserProfile(String uid, UserProfile userProfile) async {
    try {
      // Get Firestore instance
      final firestore = FirebaseFirestore.instance;

      // Save the user profile in Firestore under the 'users' collection
      await firestore.collection('users').doc(uid).set(userProfile.toMap());

      print("User profile saved successfully!");
    } catch (e) {
      print("Error saving user profile: $e");
    }
  }

}
