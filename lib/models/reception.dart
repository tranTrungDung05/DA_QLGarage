import 'package:cloud_firestore/cloud_firestore.dart';

// Model đại diện cho phiếu tiếp nhận
class Reception {
  // ID duy nhất của phiếu
  final String id;

  // ID của khách hàng
  final String customerId;
  // ID của phương tiện
  final String vehicleId;
  // ID của nhân viên phụ trách
  final String staffId;

  // Danh sách ID các dịch vụ
  final List<String> serviceIds;

  // Tổng tiền
  final double totalPrice;

  // Trạng thái: pending | in_progress | done | canceled
  final String status;

  // Thời gian tạo
  final DateTime createdAt;

  // Constructor
  Reception({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.staffId,
    required this.serviceIds,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  // Chuyển thành map để lưu vào Firestore
  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'vehicleId': vehicleId,
    'staffId': staffId,
    'serviceIds': serviceIds,
    'totalPrice': totalPrice,
    'status': status,
    'createdAt': createdAt,
  };

  // Tạo từ map lấy từ Firestore
  factory Reception.fromJson(Map<String, dynamic> json, {required String id}) {
    return Reception(
      id: id,
      customerId: json['customerId'],
      vehicleId: json['vehicleId'],
      staffId: json['staffId'],
      serviceIds: List<String>.from(json['serviceIds'] ?? []),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}
