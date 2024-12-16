import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String name;
  final String email;
  final DateTime birthday;

  UserProfile({
    required this.name,
    required this.email,
    required this.birthday,
  });

  // Convert Firestore document to UserProfile
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? 'Unknown',
      birthday: (data['birthday'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    );
  }

  // Convert UserProfile to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'birthday': Timestamp.fromDate(birthday), // Convert DateTime to Timestamp
    };
  }
}
