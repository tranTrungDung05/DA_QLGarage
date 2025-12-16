import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/service.dart';

// This file contains the service for managing service data in Firestore.

// The ServiceFirestore class handles all operations related to services in the database.
class ServiceFirestore {
  // Instance of Firestore database.
  final _db = FirebaseFirestore.instance;
  // Name of the collection in Firestore where services are stored.
  final String _collection = 'services';

  // Get a stream of all services.
  Stream<List<Service>> getServices() {
    return _db
        .collection(_collection)
        .snapshots() // Listen for changes
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Service.fromJson(doc.data(), id: doc.id),
              ) // Convert to Service
              .toList(),
        );
  }

  // Add a new service to the database.
  Future<void> addService(Service service) {
    return _db.collection(_collection).add(service.toJson());
  }

  // Update an existing service in the database.
  Future<void> updateService(Service service) {
    return _db.collection(_collection).doc(service.id).update(service.toJson());
  }

  // Delete a service from the database by its ID.
  Future<void> deleteService(String id) {
    return _db.collection(_collection).doc(id).delete();
  }
}
