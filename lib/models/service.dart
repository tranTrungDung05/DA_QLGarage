// This file defines the Service model.
// A model represents the data structure for a service in the app.

// The Service class holds information about a service offered.
class Service {
  // Unique identifier for the service.
  final String id;
  // Name of the service.
  final String name;
  // Description of what the service includes.
  final String description;
  // Price of the service in some currency.
  final double price;
  // How long the service takes in minutes (optional).
  final int? durationInMinutes;

  // Constructor to create a new Service object.
  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.durationInMinutes,
  });

  // Convert the Service object to a map for saving to Firestore database.
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    'durationInMinutes': durationInMinutes,
  };

  // Create a Service object from data loaded from Firestore.
  factory Service.fromJson(Map<String, dynamic> json, {required String id}) {
    // Get the price value from the JSON data.
    final priceValue = json['price'];

    // Convert the price to a double, handling cases where it might be an int or already a double.
    double convertedPrice;
    if (priceValue is int) {
      convertedPrice = priceValue.toDouble();
    } else if (priceValue is double) {
      convertedPrice = priceValue;
    } else {
      convertedPrice = 0.0; // Default if not a number
    }

    return Service(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: convertedPrice,
      durationInMinutes: json['durationInMinutes'] as int?,
    );
  }
}
