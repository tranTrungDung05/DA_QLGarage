import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/staff.dart';

class StaffFirestore {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'employees';

  Stream<List<Staff>> getEmployees() {
    return _db
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Staff.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<void> addEmployee(Staff emp) {
    return _db.collection(_collection).add(emp.toJson());
  }

  Future<void> updateEmployee(Staff emp) {
    return _db.collection(_collection).doc(emp.id).update(emp.toJson());
  }

  Future<void> deleteEmployee(String id) {
    return _db.collection(_collection).doc(id).delete();
  }
}
