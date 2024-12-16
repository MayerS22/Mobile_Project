class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  // Add a factory method to handle JSON deserialization
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),  // Ensure 'id' is treated as a string
      name: json['name'] ?? 'Unnamed Category',  // Provide fallback in case 'name' is missing
    );
  }

  // Add a method to serialize the object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Factory method to create a Category instance from a map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'].toString(),
      name: map['name'] ?? 'Unnamed Category',
    );
  }
}
