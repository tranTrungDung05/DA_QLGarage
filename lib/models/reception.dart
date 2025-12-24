import 'package:cloud_firestore/cloud_firestore.dart';

// Model đại diện cho phiếu tiếp nhận
class Reception {
  final String id;
  final String customerId;
  final String vehicleId;
  final List<String> staffIds;
  final List<String> serviceIds;
  final double totalPrice;
  final String status; // pending | in_progress | done | canceled
  final DateTime createdAt;

  Reception({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.staffIds,
    required this.serviceIds,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  // Chuyển thành map để lưu vào Firestore
  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'vehicleId': vehicleId,
    'staffIds': staffIds,
    'serviceIds': serviceIds,
    'totalPrice': totalPrice,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  // ✅ THÊM METHOD toMap() để tương thích với code cũ
  Map<String, dynamic> toMap() => toJson();

  // Tạo từ map lấy từ Firestore
  factory Reception.fromJson(Map<String, dynamic> json, {required String id}) {
    return Reception(
      id: id,
      customerId: json['customerId'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      staffIds: List<String>.from(json['staffIds'] ?? []),
      serviceIds: List<String>.from(json['serviceIds'] ?? []),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // ✅ THÊM METHOD fromMap() để tương thích
  factory Reception.fromMap(Map<String, dynamic> map) {
    return Reception.fromJson(map, id: map['id'] ?? '');
  }

  // Copy with để cập nhật một số field
  Reception copyWith({
    String? id,
    String? customerId,
    String? vehicleId,
    List<String>? staffIds,
    List<String>? serviceIds,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
  }) {
    return Reception(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      staffIds: staffIds ?? this.staffIds,
      serviceIds: serviceIds ?? this.serviceIds,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Reception(id: $id, status: $status, totalPrice: $totalPrice)';
  }
}
