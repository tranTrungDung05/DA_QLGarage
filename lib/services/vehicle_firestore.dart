import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/vehicle.dart';

// This file contains the service for managing vehicle data in Firestore.

// The VehicleFirestore class handles all operations related to vehicles in the database.
class VehicleFirestore {
  // Instance of Firestore database.
  final _db = FirebaseFirestore.instance;
  // Name of the collection in Firestore where vehicles are stored.
  final String _collection = 'vehicles';

  // Get a stream of all vehicles.
  Stream<List<Vehicle>> getVehicles() {
    return _db
        .collection(_collection)
        .snapshots() // Listen for changes
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Vehicle.fromJson(doc.data(), id: doc.id),
              ) // Convert to Vehicle
              .toList(),
        );
  }

  // Add a new vehicle to the database.
  Future<void> addVehicle(Vehicle v) {
    return _db.collection(_collection).add(v.toJson());
  }

  // Update an existing vehicle in the database.
  Future<void> updateVehicle(Vehicle v) {
    return _db.collection(_collection).doc(v.id).update(v.toJson());
  }

  // Delete a vehicle from the database by its ID.
  Future<void> deleteVehicle(String id) {
    return _db.collection(_collection).doc(id).delete();
  }
}
