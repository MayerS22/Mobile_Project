import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/UserProfile.dart';
import '../Services/Api-Service.dart';
import 'EditProfileScreen.dart'; // Import the EditProfileScreen here

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _apiService.getUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading user profile: $e');
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
                'Profile',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFFF2E9E4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Positioned(
            top: 60, // Adjusted position to place the buttons on top
            left: 10,
            right: 10,
            child: Row(
              children: [
                // Back Button (On the left now)
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFFF2E9E4),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                ),
                // Spacer to push the edit button to the right
                Spacer(),
                // Edit Button (On the right now)
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFFF2E9E4),
                  ),
                  onPressed: () {
                    if (_userProfile != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            userProfile: _userProfile!, // Pass the user profile
                            onProfileUpdated: () {
                              _loadUserProfile(); // Reload profile when updated
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _userProfile == null
                  ? const Center(child: Text('No profile data found'))
                  : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      // User Icon (same as EditProfileScreen)
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

                      // Name Field (read-only with same style as EditProfileScreen)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Color(0xFF22223B)),
                          color: Colors.white,
                        ),
                        child: TextField(
                          controller: TextEditingController(text: _userProfile!.name),
                          readOnly: true, // Make it read-only
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Name',
                            labelStyle: TextStyle(color: Color(0xFF22223B)),
                          ),
                          style: const TextStyle(color: Color(0xFF22223B), fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Field (read-only)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Color(0xFF22223B)),
                          color: Colors.white,
                        ),
                        child: TextField(
                          controller: TextEditingController(text: _userProfile!.email),
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Color(0xFF22223B)),
                          ),
                          style: const TextStyle(color: Color(0xFF22223B), fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Birthday (read-only)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Color(0xFF22223B)),
                          color: Colors.white,
                        ),
                        child: TextField(
                          controller: TextEditingController(
                              text: DateFormat('dd-MM-yyyy').format(_userProfile!.birthday)),
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Birthday (DD-MM-YYYY)',
                            labelStyle: TextStyle(color: Color(0xFF22223B)),
                          ),
                          style: const TextStyle(color: Color(0xFF22223B), fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
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
