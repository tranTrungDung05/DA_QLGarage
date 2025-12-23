// File: lib/services/position_firestore.dart
// Service đơn giản để CRUD Position trong Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/position.dart';

class PositionFirestore {
  // Kết nối Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tên collection trong Firestore
  final String _collection = 'positions';

  // 1. THÊM position mới
  Future<void> addPosition(Position position) async {
    await _firestore
        .collection(_collection)
        .doc(position.id)
        .set(position.toJson());
  }

  // 2. CẬP NHẬT position
  Future<void> updatePosition(Position position) async {
    await _firestore
        .collection(_collection)
        .doc(position.id)
        .update(position.toJson());
  }

  // 3. XÓA position
  Future<void> deletePosition(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // 4. LẤY TẤT CẢ positions (Stream - real-time)
  Stream<List<Position>> getPositions() {
    return _firestore
        .collection(_collection)
        .orderBy('name') // Sắp xếp theo tên
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Position.fromJson(doc.data(), id: doc.id);
          }).toList();
        });
  }

  // 5. LẤY TẤT CẢ positions (Future - 1 lần)
  Future<List<Position>> getAllPositions() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('name')
        .get();

    return snapshot.docs.map((doc) {
      return Position.fromJson(doc.data(), id: doc.id);
    }).toList();
  }

  // 6. SEED positions mặc định (chạy 1 lần)
  Future<void> seedDefaultPositions() async {
    final defaults = DefaultPositions.getDefaults();

    for (final position in defaults) {
      await addPosition(position);
    }
  }
}
