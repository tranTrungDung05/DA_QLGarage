// File: lib/models/revenue.dart
// Model cho doanh thu

class Revenue {
  final String id;
  final String receptionId;
  final String customerId;
  final String vehicleId;
  final double totalPrice;
  final List<String> serviceIds;
  final List<String> staffIds;
  final DateTime createdAt; // Thời điểm tạo reception
  final DateTime completedAt; // Thời điểm hoàn thành

  Revenue({
    required this.id,
    required this.receptionId,
    required this.customerId,
    required this.vehicleId,
    required this.totalPrice,
    required this.serviceIds,
    required this.staffIds,
    required this.createdAt,
    required this.completedAt,
  });

  // Chuyển đổi sang Map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receptionId': receptionId,
      'customerId': customerId,
      'vehicleId': vehicleId,
      'totalPrice': totalPrice,
      'serviceIds': serviceIds,
      'staffIds': staffIds,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
    };
  }

  // Tạo từ Map từ Firestore
  factory Revenue.fromMap(Map<String, dynamic> map) {
    return Revenue(
      id: map['id'] ?? '',
      receptionId: map['receptionId'] ?? '',
      customerId: map['customerId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      serviceIds: List<String>.from(map['serviceIds'] ?? []),
      staffIds: List<String>.from(map['staffIds'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : DateTime.now(),
    );
  }

  // Copy with để cập nhật một số field
  Revenue copyWith({
    String? id,
    String? receptionId,
    String? customerId,
    String? vehicleId,
    double? totalPrice,
    List<String>? serviceIds,
    List<String>? staffIds,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Revenue(
      id: id ?? this.id,
      receptionId: receptionId ?? this.receptionId,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      totalPrice: totalPrice ?? this.totalPrice,
      serviceIds: serviceIds ?? this.serviceIds,
      staffIds: staffIds ?? this.staffIds,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Thời gian hoàn thành (từ tạo đến done)
  Duration get duration => completedAt.difference(createdAt);

  // Format duration
  String get durationText {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '$days ngày $hours giờ';
    } else if (hours > 0) {
      return '$hours giờ $minutes phút';
    } else {
      return '$minutes phút';
    }
  }

  @override
  String toString() {
    return 'Revenue(id: $id, totalPrice: $totalPrice, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Revenue && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
