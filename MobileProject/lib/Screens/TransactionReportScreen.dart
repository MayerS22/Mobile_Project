import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionReportScreen extends StatefulWidget {
  @override
  _TransactionReportScreenState createState() =>
      _TransactionReportScreenState();
}

class _TransactionReportScreenState extends State<TransactionReportScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = false;

  // Method to fetch all transactions from the Firestore collection
  Future<void> _fetchTransactions() async {
    setState(() {
      _loading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();  // Fetch all documents in the 'orders' collection

      // Check if we received any documents
      if (snapshot.docs.isEmpty) {
        print("No transactions found in Firestore.");
      } else {
        print("Fetched ${snapshot.docs.length} transactions:");

        // Loop through each document to fetch the order details
        for (var doc in snapshot.docs) {
          print(doc.data());  // Print the document data

          // Get the list of items in the order
          List<dynamic> items = doc['items'];
          List<Map<String, dynamic>> itemDetails = [];

          // Loop through the items to extract item details (productId, price, quantity)
          for (var item in items) {
            // Fetch the product title based on productId
            DocumentSnapshot productDoc = await FirebaseFirestore.instance
                .collection('products')
                .doc(item['productId'])
                .get(); // Fetch product details using productId

            String productTitle = productDoc.exists ? productDoc['title'] : 'Unknown Product';

            // Add item details along with product title (no price or quantity here)
            itemDetails.add({
              'productId': item['productId'],  // Add productId
              'itemId': item['itemId'],        // Add itemId (if present in your data)
              'image': item['image'] ?? 'No image available',  // Handling null image
              'title': productTitle,  // Add product title
            });
          }

          // Fetch user data using the userId from the order
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(doc['userId'])
              .get();  // Fetch the user document using userId

          String userName = userDoc.exists ? userDoc['name'] : 'Unknown User';
          String userId = doc['userId'];  // Fetch the userId from the order document

          // Update the transaction data with order details and user info
          setState(() {
            _transactions.add({
              'userName': userName,  // Add the user's name
              'userId': userId,      // Add the user's ID
              'items': itemDetails,  // Add the item details to the transaction
              'totalPrice': doc['totalPrice'],
            });
          });
        }
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch transactions")));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions();  // Automatically fetch transactions when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transaction Report")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            if (_loading)
              Center(child: CircularProgressIndicator())
            else if (_transactions.isEmpty)
              Center(child: Text("No transactions found"))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return Card(
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Display the productId and itemId of each item in the transaction
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var item in transaction['items'])
                                    Text(
                                      'Product ID: ${item['productId']}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                            ),
                            // Display total price on the right
                            Text(
                              '\$${transaction['totalPrice'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display user ID
                            Text('User ID: ${transaction['userId']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
