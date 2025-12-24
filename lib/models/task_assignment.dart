// File: lib/models/task_assignment.dart
// Model cho phân công công việc

class TaskAssignment {
  final String id;
  final String receptionId;
  final String serviceId;
  final String serviceName;
  final String staffId;
  final String staffName;
  final String status; // pending, in_progress, done
  final DateTime createdAt;
  final DateTime? startTime;
  final DateTime? endTime;

  TaskAssignment({
    required this.id,
    required this.receptionId,
    required this.serviceId,
    required this.serviceName,
    required this.staffId,
    required this.staffName,
    required this.status,
    required this.createdAt,
    this.startTime,
    this.endTime,
  });

  // ============================================
  // CONVERT TO MAP (để lưu vào Firestore)
  // ============================================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receptionId': receptionId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'staffId': staffId,
      'staffName': staffName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  // ============================================
  // CONVERT FROM MAP (đọc từ Firestore)
  // ============================================
  factory TaskAssignment.fromMap(Map<String, dynamic> map) {
    return TaskAssignment(
      id: map['id'] ?? '',
      receptionId: map['receptionId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      startTime: map['startTime'] != null
          ? DateTime.parse(map['startTime'])
          : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
    );
  }

  // ============================================
  // COPY WITH (để cập nhật một số field)
  // ============================================
  TaskAssignment copyWith({
    String? id,
    String? receptionId,
    String? serviceId,
    String? serviceName,
    String? staffId,
    String? staffName,
    String? status,
    DateTime? createdAt,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return TaskAssignment(
      id: id ?? this.id,
      receptionId: receptionId ?? this.receptionId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  // ============================================
  // GETTERS - TIỆN ÍCH
  // ============================================

  // Trạng thái hiển thị (có icon)
  String get statusText {
    switch (status) {
      case 'pending':
        return '⏳ Đang chờ';
      case 'in_progress':
        return '🔧 Đang làm';
      case 'done':
        return '✅ Hoàn thành';
      default:
        return status;
    }
  }

  // Tính thời gian làm việc
  String get duration {
    if (startTime == null && endTime == null) {
      return 'Chưa bắt đầu';
    }

    if (startTime != null && endTime == null) {
      final now = DateTime.now();
      final diff = now.difference(startTime!);
      return 'Đang làm: ${_formatDuration(diff)}';
    }

    if (startTime != null && endTime != null) {
      final diff = endTime!.difference(startTime!);
      return 'Hoàn thành trong: ${_formatDuration(diff)}';
    }

    return '-';
  }

  // Format duration thành text dễ đọc
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} ngày ${duration.inHours % 24} giờ';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} giờ ${duration.inMinutes % 60} phút';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} phút';
    } else {
      return '${duration.inSeconds} giây';
    }
  }

  // Kiểm tra task có đang làm không
  bool get isInProgress => status == 'in_progress';

  // Kiểm tra task đã hoàn thành chưa
  bool get isDone => status == 'done';

  // Kiểm tra task có đang chờ không
  bool get isPending => status == 'pending';

  @override
  String toString() {
    return 'TaskAssignment(id: $id, serviceName: $serviceName, staffName: $staffName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskAssignment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
