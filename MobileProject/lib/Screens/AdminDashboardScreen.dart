import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:fl_chart/fl_chart.dart'; // Import the fl_chart package
import '../Models/Product.dart'; // Import your Product model
import '../Models/Category.dart';
import '../Services/Api-Service.dart'; // Import your ApiService
import 'TransactionReportScreen.dart';
import 'UserFeedbackScreen.dart'; // Firebase Firestore for report

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs: Categories, Products, Best-Selling Chart
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Method to log out
  Future<void> _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Method to create a new category
  Future<void> _createCategory(String categoryName) async {
    try {
      await _apiService.createCategory(categoryName);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Category created successfully")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to create category: $e")));
    }
  }

  // Method to create a new product
  Future<void> _createProduct(String productName, double productPrice) async {
    try {
      await _apiService.createProduct(productName, productPrice);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product created successfully")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to create product: $e")));
    }
  }

  // Method to fetch all categories
  Future<List<Category>> _fetchCategories() async {
    try {
      return await _apiService.fetchCategories();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  // Method to fetch all products
  Future<List<Product>> _fetchProducts() async {
    try {
      return await _apiService.fetchProducts();
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  // Method to fetch best-selling products
  Future<List<Map<String, dynamic>>> _fetchBestSellingProducts() async {
    try {
      return await _apiService.getBestSellingProducts();
    } catch (e) {
      print("Error fetching best-selling products: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          // Report Icon
          IconButton(
            icon: Icon(Icons.report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransactionReportScreen()),
              );
            },
          ),
          // User Feedback Icon
          IconButton(
            icon: Icon(Icons.feedback),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserFeedbackScreen()), // Navigate to feedback screen
              );
            },
          ),
          // Logout Icon
          IconButton(
            icon: Icon(Icons.exit_to_app), // Log out icon
            onPressed: _logOut,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Categories"),
            Tab(text: "Products"),
            Tab(text: "Best-Selling Chart"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Categories Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder<List<Category>>(
                    future: _fetchCategories(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text("No categories available");
                      } else {
                        List<Category> categories = snapshot.data!;
                        return Column(
                          children: categories.map((category) {
                            return ListTile(
                              title: Text(category.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showCategoryDialog(initialCategoryName: category.name, categoryId: category.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteCategory(category.id);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showCategoryDialog();
                    },
                    child: Text("Add Category"),
                  ),
                ],
              ),
            ),
          ),

          // Products Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder<List<Product>>(
                    future: _fetchProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text("No products available");
                      } else {
                        List<Product> products = snapshot.data!;
                        return Column(
                          children: products.map((product) {
                            return ListTile(
                              title: Text(product.title),
                              subtitle: Text("\$${product.price}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showProductDialog(
                                        initialProductName: product.title,
                                        initialProductPrice: product.price,
                                        productId: product.id.toString(),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteProduct(product.id.toString());
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showProductDialog();
                    },
                    child: Text("Create Product"),
                  ),
                ],
              ),
            ),
          ),

          // Best-Selling Products Chart Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<Map<String, dynamic>>>( // Best-Selling products
              future: _fetchBestSellingProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("No sales data available");
                } else {
                  List<Map<String, dynamic>> bestSellingProducts = snapshot.data!;
                  return Container(
                    height: 300,
                    padding: EdgeInsets.all(8),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 20,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(show: true),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                        barGroups: bestSellingProducts.map((product) {
                          return BarChartGroupData(
                            x: int.parse(product['productId']),
                            barRods: [
                              BarChartRodData(
                                toY: product['totalSales'],
                                color: Colors.blue,
                                width: 20,
                                borderRadius: BorderRadius.zero,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to create or update a category
  void _showCategoryDialog({String? initialCategoryName, String? categoryId}) {
    if (initialCategoryName != null) {
      _categoryNameController.text = initialCategoryName;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(categoryId == null ? 'Add Category' : 'Edit Category'),
          content: TextField(
            controller: _categoryNameController,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String categoryName = _categoryNameController.text;
                if (categoryName.isNotEmpty) {
                  if (categoryId == null) {
                    _createCategory(categoryName);
                  } else {
                    _updateCategory(categoryId, categoryName);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(categoryId == null ? 'Add' : 'Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to update category
  Future<void> _updateCategory(String categoryId, String newName) async {
    try {
      await _apiService.updateCategory(categoryId, newName);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Category updated successfully")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update category: $e")));
    }
  }

  // Method to delete category
  Future<void> _deleteCategory(String categoryId) async {
    try {
      await _apiService.deleteCategory(categoryId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Category deleted successfully")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete category: $e")));
    }
  }

  // Method to create or update a product
  void _showProductDialog({String? initialProductName, double? initialProductPrice, String? productId}) {
    if (initialProductName != null) {
      _productNameController.text = initialProductName;
    }
    if (initialProductPrice != null) {
      _productPriceController.text = initialProductPrice.toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(productId == null ? 'Add Product' : 'Edit Product'),
          content: Column(
            children: [
              TextField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _productPriceController,
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String productName = _productNameController.text;
                double productPrice = double.tryParse(_productPriceController.text) ?? 0;
                if (productName.isNotEmpty && productPrice > 0) {
                  if (productId == null) {
                    _createProduct(productName, productPrice);
                  } else {
                    _updateProduct(productId, productName, productPrice);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(productId == null ? 'Add' : 'Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to update product
  Future<void> _updateProduct(String productId, String productName, double productPrice) async {
    try {
      await _apiService.updateProduct(productId, productName, productPrice);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product updated successfully")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update product: $e")));
    }
  }

  // Method to delete product
  Future<void> _deleteProduct(String productId) async {
    try {
      await _apiService.deleteProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product deleted successfully")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete product: $e")));
    }
  }
}
