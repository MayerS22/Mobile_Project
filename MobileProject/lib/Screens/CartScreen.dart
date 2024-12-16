import 'package:flutter/material.dart';
import '../Models/Cart.dart';
import '../Services/Api-Service.dart';
import 'CheckoutScreen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _apiService = ApiService();
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _updateTotal(); // Initialize total price
  }

  // Method to calculate total price dynamically
  Future<void> _updateTotal() async {
    double total = await _apiService.calculateTotal();
    setState(() {
      _totalPrice = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shopping Cart')),
      body: StreamBuilder<List<CartItem>>(
        stream: _apiService.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Your cart is empty.'));
          }

          List<CartItem> cartItems = snapshot.data!;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return ListTile(
                leading: Image.network(item.image),
                title: Text(item.title),
                subtitle: Text('\$${item.price} x ${item.quantity}'),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () async {
                    await _apiService.removeFromCart(item.productId);
                    _updateTotal(); // Recalculate total after removing
                  },
                ),
                onTap: () {
                  _showEditQuantityDialog(context, item);
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total: \$${_totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
            ElevatedButton(
              onPressed: _checkout,
              child: Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditQuantityDialog(BuildContext context, CartItem item) {
    TextEditingController quantityController = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Quantity'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Quantity'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              int newQuantity = int.tryParse(quantityController.text) ?? item.quantity;
              await _apiService.updateQuantity(item.productId, newQuantity);
              _updateTotal(); // Recalculate total after updating quantity
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  // Method to handle checkout process
  Future<void> _checkout() async {
    // Save checkout data
    final cartItems = await _apiService.getCartItems().first; // Get the current cart items
    double total = _totalPrice;

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Your cart is empty.')));
      return;
    }

    // Navigate to confirmation page
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CheckoutScreen(cartItems: cartItems, totalPrice: total),
    ));
  }
}
