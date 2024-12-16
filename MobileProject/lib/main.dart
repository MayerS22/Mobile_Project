import 'package:flutter/material.dart';
import '';

void main() {
  runApp(const BirthdayCard());
}

class BirthdayCard extends StatelessWidget {
  const BirthdayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFD2BCD5),
        body:
            Center(child: Image(image: AssetImage('assets/BirthdayCard.jpg'))),
      ),
    );
  }
}
