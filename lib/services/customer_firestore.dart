import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/customer.dart';

class CustomerFirestore {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'customers';

  Stream<List<Customer>> streamCustomers() {
    return _db
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Customer.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<void> addCustomer(Customer c) {
    return _db.collection(_collection).add(c.toJson());
  }

  Future<void> updateCustomer(Customer c) {
    return _db.collection(_collection).doc(c.id).update(c.toJson());
  }

  Future<void> deleteCustomer(String id) {
    return _db.collection(_collection).doc(id).delete();
  }
}
