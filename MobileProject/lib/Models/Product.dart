class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String category;
  late final int quantityInStock; // Added stock quantity
  final Map<String, dynamic>? rating; // Nullable rating map
  late final int salesCount; // To track the number of sales for best-selling products

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.quantityInStock, // Initialize quantity
    this.rating,
    required this.salesCount, // Initialize sales count
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
      category: json['category'],
      quantityInStock: json['quantityInStock'] ?? 0,
      rating: json['rating'] != null ? Map<String, dynamic>.from(json['rating']) : null,
      salesCount: json['salesCount'] ?? 0, 
    );
  }

  double get ratingRate => rating?['rate']?.toDouble() ?? 0.0;
  int get ratingCount => rating?['count']?.toInt() ?? 0;

  // Method to update stock after a transaction
  void updateStock(int quantitySold) {
    quantityInStock -= quantitySold;
  }

  // Method to increment the sales count
  void incrementSales(int quantitySold) {
    salesCount += quantitySold;
  }
}
