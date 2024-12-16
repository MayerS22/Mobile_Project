import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/Cart.dart';

class CheckoutScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final double totalPrice;

  CheckoutScreen({required this.cartItems, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    leading: Image.network(item.image, width: 50, height: 50),
                    title: Text(item.title),
                    subtitle: Text('\$${item.price} x ${item.quantity}'),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text('Total: \$${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _confirmOrder(context);
              },
              child: Text('Confirm Order'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder(BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      try {
        // Save the order to Firestore and get the orderId
        final orderRef = await firestore.collection('orders').add({
          'userId': user.uid,
          'items': cartItems.map((item) => item.toMap()).toList(),
          'totalPrice': totalPrice,
          'timestamp': Timestamp.now(),
        });

        final orderId = orderRef.id; // Get the generated orderId

        // Clear the cart in Firestore
        final cartCollection = firestore.collection('carts').doc(user.uid).collection('items');
        final cartSnapshot = await cartCollection.get();
        for (var doc in cartSnapshot.docs) {
          await doc.reference.delete();
        }

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order confirmed! It will be shipped soon.')));

        // Ask for rating and feedback after confirming the order
        _showRatingDialog(context, user.uid, orderId); // Pass orderId to feedback dialog

      } catch (e) {
        print('Error confirming order: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to confirm the order.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User is not authenticated.')));
    }
  }

  Future<void> _showRatingDialog(BuildContext context, String userId, String orderId) async {
    final TextEditingController feedbackController = TextEditingController();
    int rating = 0;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must provide feedback
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rate Your Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rating stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                    ),
                    onPressed: () {
                      rating = index + 1;
                    },
                  );
                }),
              ),
              SizedBox(height: 10),
              // Feedback TextField
              TextField(
                controller: feedbackController,
                decoration: InputDecoration(
                  hintText: 'Leave your feedback here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                // Save rating and feedback to Firestore
                if (rating > 0) {
                  await FirebaseFirestore.instance.collection('order_feedbacks').add({
                    'userId': userId,
                    'orderId': orderId, // Include orderId
                    'rating': rating,
                    'feedback': feedbackController.text.trim(),
                    'timestamp': Timestamp.now(),
                  });

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thank you for your feedback!')));

                  // Close the dialog and go back to the main screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else {
                  // Show error message if no rating is selected
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please give a rating!')));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
