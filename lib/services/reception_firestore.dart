import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/reception.dart';

// Dịch vụ quản lý dữ liệu phiếu tiếp nhận trong Firestore
class ReceptionFirestore {
  // Instance của Firestore
  final _db = FirebaseFirestore.instance;
  // Tên collection trong Firestore
  final _col = 'receptions';

  // Lấy stream danh sách receptions, sắp xếp theo thời gian tạo giảm dần
  Stream<List<Reception>> getReceptions() {
    return _db
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Reception.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  // Thêm phiếu tiếp nhận mới
  Future<void> addReception(Reception reception) {
    return _db.collection(_col).add(reception.toJson());
  }

  // Cập nhật trạng thái của phiếu tiếp nhận
  Future<void> updateStatus(String id, String status) {
    return _db.collection(_col).doc(id).update({'status': status});
  }

  // Cập nhật toàn bộ phiếu tiếp nhận
  Future<void> updateReception(Reception reception) {
    return _db.collection(_col).doc(reception.id).update(reception.toJson());
  }

  // Xóa phiếu tiếp nhận
  Future<void> deleteReception(String id) {
    return _db.collection(_col).doc(id).delete();
  }
}
