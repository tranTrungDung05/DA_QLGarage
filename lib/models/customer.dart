// This file defines the Customer model.
// A model represents the data structure for a customer in the app.

// The Customer class holds information about a customer.
class Customer {
  // Unique identifier for the customer.
  final String id;
  // Phone number of the customer.
  final String phoneNumber;
  // Name of the customer.
  final String name;
  // Email address of the customer (optional).
  final String? email;
  // Address of the customer (optional).
  final String? address;

  // Constructor to create a new Customer object.
  // Required fields must be provided, optional ones can be null.
  Customer({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.email,
    this.address,
  });

  // Convert the Customer object to a map (dictionary) for saving to database.
  // This is used when storing data in Firestore.
  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'name': name,
    'email': email,
    'address': address,
  };

  // Create a Customer object from a map (dictionary) loaded from database.
  // This is used when reading data from Firestore.
  // The id is passed separately because it's the document ID in Firestore.
  factory Customer.fromJson(Map<String, dynamic> json, {required String id}) {
    return Customer(
      id: id,
      phoneNumber: json['phoneNumber'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
    );
  }
}
