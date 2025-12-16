import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/staff.dart';

// This file contains the service for managing staff data in Firestore.

// The StaffFirestore class handles all operations related to staff in the database.
class StaffFirestore {
  // Instance of Firestore database.
  final _db = FirebaseFirestore.instance;
  // Name of the collection in Firestore where staff are stored.
  final String _collection = 'employees';

  // Get a stream of all staff members.
  Stream<List<Staff>> getEmployees() {
    return _db
        .collection(_collection)
        .snapshots() // Listen for changes
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Staff.fromJson(doc.data(), id: doc.id),
              ) // Convert to Staff
              .toList(),
        );
  }

  // Add a new staff member to the database.
  Future<void> addEmployee(Staff emp) {
    return _db.collection(_collection).add(emp.toJson());
  }

  // Update an existing staff member in the database.
  Future<void> updateEmployee(Staff emp) {
    return _db.collection(_collection).doc(emp.id).update(emp.toJson());
  }

  // Delete a staff member from the database by their ID.
  Future<void> deleteEmployee(String id) {
    return _db.collection(_collection).doc(id).delete();
  }
}
