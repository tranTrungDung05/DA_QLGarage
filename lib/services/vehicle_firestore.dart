import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/vehicle.dart';

class VehicleFirestore {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'vehicles';

  Stream<List<Vehicle>> getVehicles() {
    return _db
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Vehicle.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<void> addVehicle(Vehicle v) {
    return _db.collection(_collection).add(v.toJson());
  }

  Future<void> updateVehicle(Vehicle v) {
    return _db.collection(_collection).doc(v.id).update(v.toJson());
  }

  Future<void> deleteVehicle(String id) {
    return _db.collection(_collection).doc(id).delete();
  }
}
