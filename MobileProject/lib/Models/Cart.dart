import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final String title;
  final double price;
  final String image;
  final int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
    };
  }

  static CartItem fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      productId: data['productId'],
      title: data['title'],
      price: data['price'],
      image: data['image'],
      quantity: data['quantity'],
    );
  }
}
