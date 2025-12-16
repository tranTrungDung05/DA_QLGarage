// This file defines the Vehicle model.
// A model represents the data structure for a vehicle in the app.

// The Vehicle class holds information about a vehicle.
class Vehicle {
  // Unique identifier for the vehicle.
  final String id;
  // Brand of the vehicle (e.g., Toyota).
  final String brand;
  // Model of the vehicle (e.g., Camry).
  final String model;
  // Year the vehicle was made.
  final int year;
  // License plate number of the vehicle.
  final String plateNumber;
  // Color of the vehicle (optional).
  final String? color;

  // Constructor to create a new Vehicle object.
  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plateNumber,
    this.color,
  });

  // Convert the Vehicle object to a map for saving to Firestore.
  Map<String, dynamic> toJson() => {
    'brand': brand,
    'model': model,
    'year': year,
    'plateNumber': plateNumber,
    'color': color,
  };

  // Create a Vehicle object from data loaded from Firestore.
  factory Vehicle.fromJson(Map<String, dynamic> json, {required String id}) {
    return Vehicle(
      id: id,
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      // Convert year to int, default to 0 if not present.
      year: (json['year'] as num?)?.toInt() ?? 0,
      plateNumber: json['plateNumber'] ?? '',
      color: json['color'] as String?,
    );
  }
}
