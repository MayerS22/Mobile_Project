import 'package:flutter/material.dart';
import 'package:e_commerce/Models/Category.dart';
import '../Services/Api-Service.dart';
import 'ProductListScreen.dart';

class CategoryListScreen extends StatefulWidget {
  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final apiService = ApiService();
      final fetchedCategories = await apiService.fetchCategories();
      setState(() {
        categories = fetchedCategories;
      });
      print(fetchedCategories);  // Check what is being fetched
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories' ,style: TextStyle(color: Colors.white),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF4A4E69), // Same as the button color in HomeScreen
      ),
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Gradient Background (same as HomeScreen)
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xFF22223B),
                Color(0xFF4A4E69),
                Color(0xFF9A8C98),
                Color(0xFFC9ADA7),
                Color(0xFFF2E9E4),
              ]),
            ),
          ),
          // Category Grid
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two categories per row
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1.2, // Adjust aspect ratio for card size
                ),
                itemCount: categories.length,
                shrinkWrap: true, // To prevent overflow and allow scrolling
                physics: NeverScrollableScrollPhysics(), // Disable scroll for grid inside scroll view
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the Product List screen for the selected category
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductListScreen(categoryId: category.id),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A4E69), // Same color as button
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon as a placeholder
                            Icon(
                              Icons.category_outlined,
                              size: 50.0,
                              color: Colors.white,
                            ),
                            SizedBox(height: 10),
                            // Category Name
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
