import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Models/Product.dart';
import '../Services/Api-Service.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final ApiService _apiService = ApiService();

  ProductDetailsScreen({required this.product});

  Future<void> _addToCart(Product product, BuildContext context) async {
    try {
      await _apiService.addToCart(product);
      Fluttertoast.showToast(
        msg: "Product added to cart",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      print('Error adding product to cart: $e');
      Fluttertoast.showToast(
        msg: "Failed to add product to cart",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(product.image, height: 300, fit: BoxFit.cover),
            ),
            SizedBox(height: 20),
            Text(product.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(product.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, color: Colors.green)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addToCart(product, context),
              child: Text('Add to Cart'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
