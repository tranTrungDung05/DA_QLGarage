import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/reception.dart';

// Dịch vụ quản lý dữ liệu phiếu tiếp nhận trong Firestore
class ReceptionFirestore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _col = 'receptions';

  CollectionReference get _collection => _db.collection(_col);

  // Lấy stream danh sách receptions
  Stream<List<Reception>> getReceptions() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Reception.fromJson(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ),
              )
              .toList(),
        );
  }

  // ✅ THÊM: Lấy một reception theo ID
  Future<Reception?> getReceptionById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Reception.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
  }

  // Thêm phiếu tiếp nhận mới
  Future<void> addReception(Reception reception) {
    return _collection.doc(reception.id).set(reception.toJson());
  }

  // Cập nhật trạng thái của phiếu tiếp nhận
  Future<void> updateStatus(String id, String status) {
    return _collection.doc(id).update({'status': status});
  }

  // Cập nhật toàn bộ phiếu tiếp nhận
  Future<void> updateReception(Reception reception) {
    return _collection.doc(reception.id).update(reception.toJson());
  }

  // Xóa phiếu tiếp nhận
  Future<void> deleteReception(String id) {
    return _collection.doc(id).delete();
  }

  // ✅ THÊM: Get all receptions (for revenue calculation)
  Future<List<Reception>> getAllReceptions() async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map(
          (doc) => Reception.fromJson(
            doc.data() as Map<String, dynamic>,
            id: doc.id,
          ),
        )
        .toList();
  }
}
