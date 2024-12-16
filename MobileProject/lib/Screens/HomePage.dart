import 'package:flutter/material.dart';
import 'package:e_commerce/components/discountBanner.dart';
import 'package:e_commerce/components/CustomSearchBar.dart';
import 'package:e_commerce/components/SearchResultScreen.dart';
import 'package:e_commerce/Screens/CategoryListScreen.dart';
import 'package:e_commerce/Screens/CartScreen.dart'; // Import the Cart Screen
import 'package:e_commerce/Screens/SignInScreen.dart'; // Import SignIn screen
import '../Services/Api-Service.dart';
import '../components/PopularProducts.dart';
import '../Screens/ProfileScreen.dart'; // Import Profile screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Function for search query handling
  void onSearch(String query) async {
    try {
      final results = await ApiService().searchProducts(query);
      if (mounted) {  // Check if the widget is still in the widget tree
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultScreen(results: results),
          ),
        );
      }
    } catch (e) {
      if (mounted) {  // Ensure no updates are made after the widget is disposed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch search results.')),
        );
      }
    }
  }

  // Logout function to handle the logout action
  void _logout() async {
    // You can use any logout logic like clearing the session, token, or user data
    // For now, let's just navigate to the SignIn screen.

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  // Show confirmation dialog for logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _logout(); // Perform logout and navigate to SignIn
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24,color: Colors.white)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF4A4E69), // Same as the SignUp button color
        actions: [
          // Cart icon button in the AppBar
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              // Navigate to Cart screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()), // Navigate to Cart Screen
              );
            },
          ),

          // Profile icon button in the AppBar
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // Navigate to Profile screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),

          // Logout icon button in the AppBar
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _showLogoutDialog, // Show logout confirmation dialog
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient Background (same as SignInScreen)
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding for the content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Custom Search Bar at the top
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20), // Adding space above and below the search bar
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color of the search bar
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                        boxShadow: [  // Subtle shadow for depth
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomSearchBar(
                        onSearch: onSearch,
                      ),
                    ),
                  ),

                  // Discount Banner with spacing
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.1), // Light background color
                        borderRadius: BorderRadius.circular(10), // Rounded corners for the banner
                      ),
                      child: Discount(),
                    ),
                  ),

                  // Popular Products Carousel
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: PopularProducts(
                      apiUrl: 'https://fakestoreapi.com/products',  // Sample API URL
                      itemCount: 1,  // Display 1 product per slide
                      autoPlay: true,  // Enable auto-play for carousel
                    ),
                  ),

                  // View Categories Button (styled like the sign-up button)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      height: 60, // Increased button height
                      width: 250, // Adjust width to make it more prominent
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CategoryListScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF4A4E69), // Same color as the SignUp button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Rounded corners
                          ),
                          minimumSize: Size(double.infinity, 50), // Full-width button
                        ),
                        child: const Text(
                          'View Categories',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
