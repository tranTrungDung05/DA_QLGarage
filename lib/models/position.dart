class Position {
  /// ID duy nhất của vị trí
  final String id;

  /// Tên vị trí (VD: "Kỹ sư cơ khí", "Thợ điện", "Nhân viên rửa xe")
  final String name;

  /// Mô tả công việc
  final String? description;

  /// Mức lương cơ bản cho vị trí này (tham khảo)
  final double? baseSalary;

  /// Yêu cầu kỹ năng
  final List<String>? requiredSkills;

  /// Trạng thái hoạt động
  final bool isActive;

  /// Ngày tạo
  final DateTime createdAt;

  /// Ngày cập nhật
  final DateTime? updatedAt;

  Position({
    required this.id,
    required this.name,
    this.description,
    this.baseSalary,
    this.requiredSkills,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'baseSalary': baseSalary,
    'requiredSkills': requiredSkills,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Create from Firestore JSON
  factory Position.fromJson(Map<String, dynamic> json, {String? id}) {
    return Position(
      id: id ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      baseSalary: json['baseSalary'] != null
          ? (json['baseSalary'] as num).toDouble()
          : null,
      requiredSkills: json['requiredSkills'] != null
          ? List<String>.from(json['requiredSkills'])
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Copy with
  Position copyWith({
    String? id,
    String? name,
    String? description,
    double? baseSalary,
    List<String>? requiredSkills,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Position(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseSalary: baseSalary ?? this.baseSalary,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Position(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Các Position mặc định cho garage
class DefaultPositions {
  static const mechanicEngineer = 'mechanic_engineer';
  static const electrician = 'electrician';
  static const bodyWorkTechnician = 'body_work_technician';
  static const paintTechnician = 'paint_technician';
  static const carWasher = 'car_washer';
  static const receptionist = 'receptionist';
  static const manager = 'manager';

  static List<Position> getDefaults() => [
    Position(
      id: mechanicEngineer,
      name: 'Kỹ sư cơ khí',
      description: 'Chuyên sửa chữa động cơ, hộp số, hệ thống truyền động',
      baseSalary: 15000000,
      requiredSkills: ['Sửa động cơ', 'Kiểm tra hệ thống', 'Bảo dưỡng'],
    ),
    Position(
      id: electrician,
      name: 'Thợ điện',
      description: 'Chuyên sửa chữa hệ thống điện xe, điện tử',
      baseSalary: 12000000,
      requiredSkills: ['Sửa hệ thống điện', 'Kiểm tra cảm biến'],
    ),
    Position(
      id: bodyWorkTechnician,
      name: 'Thợ sửa chữa thân vỏ',
      description: 'Sửa chữa thân xe, khung xe sau tai nạn',
      baseSalary: 10000000,
      requiredSkills: ['Hàn', 'Sửa thân xe', 'Chỉnh khung'],
    ),
    Position(
      id: paintTechnician,
      name: 'Thợ sơn',
      description: 'Sơn xe, phục hồi màu sơn',
      baseSalary: 11000000,
      requiredSkills: ['Sơn xe', 'Phục hồi màu', 'Đánh bóng'],
    ),
    Position(
      id: carWasher,
      name: 'Nhân viên rửa xe',
      description: 'Rửa xe, vệ sinh xe',
      baseSalary: 7000000,
      requiredSkills: ['Rửa xe', 'Vệ sinh nội thất'],
    ),
    Position(
      id: receptionist,
      name: 'Lễ tân',
      description: 'Tiếp nhận khách hàng, tư vấn dịch vụ',
      baseSalary: 8000000,
      requiredSkills: ['Tư vấn', 'Giao tiếp'],
    ),
    Position(
      id: manager,
      name: 'Quản lý',
      description: 'Quản lý garage, điều phối nhân viên',
      baseSalary: 20000000,
      requiredSkills: ['Quản lý', 'Điều phối', 'Giám sát'],
    ),
  ];
}
