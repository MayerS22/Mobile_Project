import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/Product.dart';
import '../Models/Category.dart';
import '../Models/UserProfile.dart';
import '../Models/Cart.dart';

class ApiService {
  final String productBaseUrl = 'https://fakestoreapi.com/products';
  final String categoryBaseUrl = 'https://fakestoreapi.com/products/categories';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------------------------------------
  // Profile Operations
  // ---------------------------------------------

// Fetch user profile data or create a new profile if it doesn't exist
  Future<UserProfile?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Fetch data from the 'users' collection
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          // Map the Firestore document to a UserProfile object
          return UserProfile.fromFirestore(doc);
        } else {
          // If the document doesn't exist, create a new user profile with fallback data
          final newUserProfile = UserProfile(
            name: user.displayName ?? 'User', // Fallback name
            email: user.email ?? 'email@example.com', // Fallback email
            birthday: DateTime.now(), // Fallback birthday
          );

          // Save the new user profile to the 'users' collection
          await _firestore.collection('users').doc(user.uid).set(newUserProfile.toMap());

          return newUserProfile;
        }
      } catch (e) {
        print('Error fetching or saving user profile: $e');
        return null;
      }
    } else {
      print("No user is currently authenticated.");
      return null;
    }
  }

// Save or update user profile data in the 'users' collection
  Future<void> saveUserProfile(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user != null) {
      // Save the updated profile to the 'users' collection
      await _firestore.collection('users').doc(user.uid).set(profile.toMap());
    }
  }

  // ---------------------------------------------
  // Category Operations
  // ---------------------------------------------

  // Fetch all categories
  Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(categoryBaseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((categoryName) {
          return Category(
            id: categoryName,
            name: categoryName,
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch categories: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in fetchCategories: $e');
      rethrow;
    }
  }


  // ---------------------------------------------
  // Product Operations
  // ---------------------------------------------

  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(productBaseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((productJson) => Product.fromJson(productJson)).toList();
      } else {
        throw Exception('Failed to fetch products: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in fetchProducts: $e');
      rethrow;
    }
  }

  // Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final url = '$productBaseUrl/category/$category';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((productJson) => Product.fromJson(productJson)).toList();
      } else {
        throw Exception('Failed to fetch products for category "$category": ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in fetchProductsByCategory: $e');
      rethrow;
    }
  }

  // Search products by query
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(Uri.parse(productBaseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map((productJson) => Product.fromJson(productJson))
            .where((product) => product.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        throw Exception('Failed to fetch products: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in searchProducts: $e');
      rethrow;
    }
  }

  // ---------------------------------------------
  // Cart Operations
  // ---------------------------------------------

  // Add item to the cart
  Future<void> addToCart(Product product) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final cartCollection = _firestore.collection('carts').doc(user.uid).collection('items');
        final productId = product.id.toString();

        final cartQuery = await cartCollection.where('productId', isEqualTo: productId).get();

        if (cartQuery.docs.isEmpty) {
          // Add product to cart if it's not already in the cart
          await cartCollection.doc(productId).set({
            'productId': productId,
            'title': product.title,
            'price': product.price,
            'image': product.image,
            'quantity': 1,
          });
        } else {
          // Update quantity if already in the cart
          final cartDoc = cartQuery.docs.first;
          await cartDoc.reference.update({
            'quantity': FieldValue.increment(1),
          });
        }
      } catch (e) {
        print('Error adding product to cart: $e');
      }
    } else {
      print("User is not authenticated");
    }
  }

  // Remove item from the cart
  Future<void> removeFromCart(String productId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('carts').doc(user.uid).collection('items').doc(productId).delete();
      } catch (e) {
        print("Error removing item from cart: $e");
      }
    } else {
      print("User not authenticated.");
    }
  }

  // Update product quantity in the cart
  Future<void> updateQuantity(String productId, int quantity) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('carts')
            .doc(user.uid)
            .collection('items')
            .doc(productId)
            .update({'quantity': quantity});
      } catch (e) {
        print("Error updating quantity: $e");
      }
    } else {
      print("User not authenticated.");
    }
  }

  // Fetch all items in the cart
  Stream<List<CartItem>> getCartItems() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList());
    } else {
      print("No user authenticated");
      return Stream.value([]);
    }
  }

  // Calculate total price of cart
  Future<double> calculateTotal() async {
    User? user = _auth.currentUser;
    double total = 0.0;
    if (user != null) {
      QuerySnapshot snapshot = await _firestore.collection('carts').doc(user.uid).collection('items').get();
      for (var doc in snapshot.docs) {
        CartItem cartItem = CartItem.fromFirestore(doc);
        total += cartItem.price * cartItem.quantity;
      }
    }
    return total;
  }
  // Fetch all user profiles
  Future<List<UserProfile>> fetchAllUsers() async {
    try {
      // Note: To get a list of users, you typically need to use Firebase Admin SDK or a backend service.
      // Here, we can only fetch the current user for the Flutter app:
      List<UserProfile> users = [];

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        users.add(
          UserProfile(
            name: currentUser.displayName ?? 'Unknown',
            email: currentUser.email ?? 'No email',
            birthday: DateTime.now(), // Default for this example
          ),
        );
      }

      return users;
    } catch (e) {
      print('Error fetching users from Firebase Authentication: $e');
      return [];
    }
  }

  Future<void> deleteUser(String email) async {
    try {
      // First, delete the user profile from Firestore
      final userProfiles = await _firestore
          .collection('profiles')
          .where('email', isEqualTo: email)
          .get();

      if (userProfiles.docs.isNotEmpty) {
        // If user profile exists, delete it from Firestore
        for (var profile in userProfiles.docs) {
          await profile.reference.delete();
        }
      }

      // Then, delete the user from Firebase Authentication
      final user = await _auth.fetchSignInMethodsForEmail(email);
      if (user.isNotEmpty) {
        final authUser = _auth.currentUser;
        if (authUser != null && authUser.email == email) {
          // If the user is logged in, delete them
          await authUser.delete();
        } else {
          // Otherwise, delete the user from Firebase Authentication
          await _auth.currentUser!.delete();
        }
      }
    } catch (e) {
      throw 'Error deleting user: $e';
    }
  }


  // Add user to Firebase Authentication and Firestore
  Future<void> addUser(String email, String password, String name) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      final newUserProfile = UserProfile(
        name: name,
        email: email,
        birthday: DateTime.now(), // Default birthday (can be updated later)
      );

      await _firestore.collection('profiles').doc(userCredential.user!.uid).set(newUserProfile.toMap());

      print('User created and added to Firestore');
    } catch (e) {
      print('Error adding user: $e');
    }
  }



//create category
  Future<void> createCategory(String categoryName) async {
    try {
      final response = await http.post(
        Uri.parse('$categoryBaseUrl'),
        body: {'name': categoryName},
      );
      if (response.statusCode == 201) {
        print("Category created successfully");

        // After creating, refresh the categories list
        fetchCategories(); // This will refetch the categories and update the UI
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("API error: $e");
    }
  }

// Update category
  Future<void> updateCategory(String id, String newName) async {
    final response = await http.put(
      Uri.parse('$categoryBaseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': newName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update category');
    }
  }


// Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      final url = Uri.parse('$categoryBaseUrl/$categoryId');
      final response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Refetch categories after successful deletion
        await fetchCategories();
        print('Category with ID $categoryId deleted successfully.');
      } else {
        throw Exception('Failed to delete category. Error: ${response.body}');
      }
    } catch (e) {
      print('Error while deleting category: $e');
      throw Exception('Error while deleting category: $e');
    }
  }

  //create product
  Future<void> createProduct(String productName, double productPrice) async {
    final response = await http.post(
      Uri.parse('$productBaseUrl'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': productName,
        'price': productPrice,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create product');
    }
  }
// Update product
  Future<void> updateProduct(String id, String title, double price) async {
    final response = await http.put(
      Uri.parse('$productBaseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title, 'price': price}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }
//update product
  Future<void> deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse('$productBaseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }
// Fetch best-selling products based on order quantity
  Future<List<Map<String, dynamic>>> getBestSellingProducts() async {
    try {
      // Fetch all orders
      QuerySnapshot ordersSnapshot = await _firestore.collection('orders').get();

      // Create a map to store aggregated product sales
      Map<String, int> productSales = {};

      // Loop through each order and aggregate product quantities
      for (var order in ordersSnapshot.docs) {
        var items = order['items'];
        for (var item in items) {
          String productId = item['productId'];
          int quantity = item['quantity'];

          if (productSales.containsKey(productId)) {
            productSales[productId] = productSales[productId]! + quantity;
          } else {
            productSales[productId] = quantity;
          }
        }
      }

      // Convert the map into a list of product sales for charting
      List<Map<String, dynamic>> bestSellingProducts = [];
      productSales.forEach((productId, quantity) {
        bestSellingProducts.add({'productId': productId, 'quantity': quantity});
      });

      // Sort by quantity in descending order to get best sellers
      bestSellingProducts.sort((a, b) => b['quantity'].compareTo(a['quantity']));

      return bestSellingProducts;
    } catch (e) {
      print('Error fetching best-selling products: $e');
      return [];
    }
  }


}
