import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting and parsing
import '../Models/UserProfile.dart';
import '../Services/Api-Service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  final VoidCallback onProfileUpdated;

  const EditProfileScreen({
    Key? key,
    required this.userProfile,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _birthdayController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _birthdayController = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(widget.userProfile.birthday),
    );
  }

  // Method to show the date picker and update the birthday text field
  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime initialDate = widget.userProfile.birthday;
    final DateTime firstDate = DateTime(1900);  // Set a minimum date range
    final DateTime lastDate = DateTime.now();  // Set maximum date range

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null && selectedDate != initialDate) {
      setState(() {
        // Update the text field with the selected date in the correct format
        _birthdayController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Parse the birthday back to DateTime
        final DateTime birthday = DateFormat('dd-MM-yyyy').parse(_birthdayController.text);

        final updatedProfile = UserProfile(
          name: _nameController.text,
          email: _emailController.text,
          birthday: birthday,
        );

        await _apiService.saveUserProfile(updatedProfile);
        widget.onProfileUpdated();
        Navigator.pop(context); // Navigate back to the previous screen
      } catch (e) {
        print('Error saving profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile')),
        );
      }
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
              padding: EdgeInsets.only(top: 62, left: 60),
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFFF2E9E4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Custom Back Button
          Positioned(
            top: 60,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFFF2E9E4)),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
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
                    key: _formKey,
                    child: Column(
                      children: [
                        // User Icon (same as SignInScreen)
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

                        // Name Field
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Color(0xFF22223B)),
                            color: Colors.white,
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Name',
                              labelStyle: TextStyle(color: Color(0xFF22223B)),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Name cannot be empty' : null,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Color(0xFF22223B)),
                            color: Colors.white,
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Color(0xFF22223B)),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Email cannot be empty'
                                : (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)
                                ? 'Enter a valid email address'
                                : null),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Birthday Input
                        GestureDetector(
                          onTap: () => _selectBirthday(context), // Open date picker when tapped
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Color(0xFF22223B)),
                              color: Colors.white,
                            ),
                            child: AbsorbPointer(  // Prevent manual editing
                              child: TextFormField(
                                controller: _birthdayController,
                                readOnly: true, // Prevent manual typing
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Birthday (DD-MM-YYYY)',
                                  labelStyle: TextStyle(color: Color(0xFF22223B)),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Birthday cannot be empty';
                                  }
                                  try {
                                    DateFormat('dd-MM-yyyy').parse(value);
                                  } catch (_) {
                                    return 'Enter a valid date in DD-MM-YYYY format';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Save Button
                        Container(
                          height: 45,
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor: const Color(0xFF22223B),
                            ),
                            child: const Text(
                              "Save",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
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
