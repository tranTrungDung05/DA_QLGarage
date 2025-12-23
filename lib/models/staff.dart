// File: lib/models/staff.dart
// Model đơn giản cho Staff (Nhân viên)

class Staff {
  final String id; // ID duy nhất
  final String name; // Tên nhân viên
  final String positionId; // ID của Position
  final String positionName; // Tên Position (lưu luôn để hiển thị nhanh)
  double salary; // Lương

  Staff({
    required this.id,
    required this.name,
    required this.positionId,
    required this.positionName,
    required this.salary,
  });

  // Chuyển Staff thành Map để lưu vào Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'positionId': positionId,
      'positionName': positionName,
      'salary': salary,
    };
  }

  // Tạo Staff từ dữ liệu Firestore
  factory Staff.fromJson(Map<String, dynamic> json, {String? id}) {
    return Staff(
      id: id ?? json['id'] ?? '',
      name: json['name'] ?? '',
      positionId: json['positionId'] ?? '',
      positionName: json['positionName'] ?? '',
      salary: json['salary'] != null ? (json['salary'] as num).toDouble() : 0.0,
    );
  }
}
