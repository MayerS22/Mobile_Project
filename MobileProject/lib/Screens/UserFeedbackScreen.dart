import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class UserFeedbackScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchFeedback() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('order_feedbacks').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching feedback: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Feedback"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFeedback(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No feedback available"));
          } else {
            List<Map<String, dynamic>> feedbackList = snapshot.data!;
            return ListView.builder(
              itemCount: feedbackList.length,
              itemBuilder: (context, index) {
                var feedback = feedbackList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(feedback['feedback'] ?? 'No feedback'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("User ID: ${feedback['userId']}"),
                        Text("Rating: ${feedback['rating']}"),
                        Text("Date: ${feedback['timestamp']?.toDate().toString()}"),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
