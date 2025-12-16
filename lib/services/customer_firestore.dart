import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/customer.dart';

// This file contains the service for managing customer data in Firestore.
// Firestore is a cloud database provided by Firebase.

// The CustomerFirestore class handles all operations related to customers in the database.
class CustomerFirestore {
  // Instance of Firestore database.
  final _db = FirebaseFirestore.instance;
  // Name of the collection in Firestore where customers are stored.
  final String _collection = 'customers';

  // Get a stream of all customers.
  // A stream provides real-time updates when data changes in the database.
  Stream<List<Customer>> streamCustomers() {
    return _db
        .collection(_collection)
        .snapshots() // Listen for changes in the collection
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Customer.fromJson(doc.data(), id: doc.id),
              ) // Convert each document to Customer
              .toList(), // Convert to list
        );
  }

  // Add a new customer to the database.
  Future<void> addCustomer(Customer c) {
    return _db.collection(_collection).add(c.toJson());
  }

  // Update an existing customer in the database.
  Future<void> updateCustomer(Customer c) {
    return _db.collection(_collection).doc(c.id).update(c.toJson());
  }

  // Delete a customer from the database by their ID.
  Future<void> deleteCustomer(String id) {
    return _db.collection(_collection).doc(id).delete();
  }
}
