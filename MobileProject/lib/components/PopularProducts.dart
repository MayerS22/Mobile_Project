import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_commerce/Screens/ProductDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../Models/Product.dart';  // Make sure to import the Product model

class PopularProducts extends StatefulWidget {
  final String apiUrl;  // Allow passing a dynamic URL to fetch products
  final int itemCount;  // Specify how many items per slide
  final bool autoPlay;  // Option to auto-play the carousel

  // Constructor with default values
  const PopularProducts({
    Key? key,
    this.apiUrl = 'https://fakestoreapi.com/products',  // Default API URL
    this.itemCount = 2,  // Default 2 products per slide
    this.autoPlay = true,  // Default auto-play enabled
  }) : super(key: key);

  @override
  State<PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
  List<Product> products = [];  // Store products as a list of Product models
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();  // Fetch product data when widget initializes
  }

  // Fetch product data from an API and map it to Product models
  void getData() async {
    try {
      var response = await Dio().get(widget.apiUrl);

      print("API Response: ${response.data}"); // Debugging the response

      if (response.statusCode == 200) {
        List<dynamic> productData = response.data;  // Assuming response is a list, adjust if it's a map
        if (productData.isNotEmpty) {
          setState(() {
            products = productData
                .map((json) => Product.fromJson(json))
                .toList();
            isLoading = false;
          });
        } else {
          print("No products found.");
          setState(() => isLoading = false);
        }
      } else {
        print("Error fetching data: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  // Custom builder function to display products per slide
  Widget _buildProducts(BuildContext context, int index, int realIndex) {
    final startIndex = index * widget.itemCount;
    final endIndex = (startIndex + widget.itemCount) > products.length
        ? products.length
        : startIndex + widget.itemCount; // Ensure we don't exceed list length

    final currentProducts = products.sublist(startIndex, endIndex);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,  // Align the products to the center
      children: currentProducts
          .map((product) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),  // Add padding between products
        child: _buildProduct(product),
      ))
          .toList(),
    );
  }

  // Helper function to build an individual product widget
  Widget _buildProduct(Product product) {
    return GestureDetector(
      onTap: () {
        // Navigate to the product details page when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 2 - 24, // Adjusting the width to avoid overflow
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1.02,
              child: Container(
                padding: EdgeInsets.all(8), // Adjusted padding
                decoration: BoxDecoration(
                  color: const Color(0xFF979797).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain, // Adjusted image scaling
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.title,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Color(0xff4a4e69),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              "\$${product.price.toString()}",
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Color(0xff4a4e69),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
      height: 280,  // Adjusted height for better fitting
      child: CarouselSlider.builder(
        itemCount: (products.length / widget.itemCount).ceil(),  // Display products per slide
        itemBuilder: _buildProducts,  // Use the custom builder function
        options: CarouselOptions(
          autoPlay: widget.autoPlay,  // Control auto-play behavior
          autoPlayInterval: Duration(seconds: 3),
          aspectRatio: 1.5,
          enlargeCenterPage: false,
          viewportFraction: 0.85, // Allow a little margin for spacing
        ),
      ),
    );
  }
}
