import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/service.dart';

class ServiceFirestore {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'services';

  Stream<List<Service>> getServices() {
    return _db
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Service.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<void> addService(Service service) {
    return _db.collection(_collection).add(service.toJson());
  }

  Future<void> updateService(Service service) {
    return _db.collection(_collection).doc(service.id).update(service.toJson());
  }

  Future<void> deleteService(String id) {
    return _db.collection(_collection).doc(id).delete();
  }
}
