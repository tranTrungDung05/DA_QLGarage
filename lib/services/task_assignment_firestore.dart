// File: lib/services/task_assignment_firestore.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application/models/task_assignment.dart';

class TaskAssignmentFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  CollectionReference get _collection =>
      _firestore.collection('task_assignments');

  CollectionReference get _receptionsCollection =>
      _firestore.collection('receptions');

  CollectionReference get _revenuesCollection =>
      _firestore.collection('revenues');

  // Tự động tạo tasks từ reception
  Future<void> autoCreateTasksFromReception({
    required String receptionId,
    required List<String> serviceIds,
    required List<String> serviceNames,
    required List<String> staffIds,
    required List<String> staffNames,
  }) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (int i = 0; i < serviceIds.length; i++) {
      final taskId = _uuid.v4();

      final task = TaskAssignment(
        id: taskId,
        receptionId: receptionId,
        serviceId: serviceIds[i],
        serviceName: serviceNames[i],
        staffId: staffIds[i],
        staffName: staffNames[i],
        status: 'pending',
        createdAt: now,
      );

      final docRef = _collection.doc(taskId);
      batch.set(docRef, task.toMap());
    }

    await batch.commit();
  }

  // Stream tasks theo reception ID
  Stream<List<TaskAssignment>> getTasksByReception(String receptionId) {
    return _collection
        .where('receptionId', isEqualTo: receptionId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TaskAssignment.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  // Stream tasks theo staff ID
  Stream<List<TaskAssignment>> getTasksByStaff(String staffId) {
    return _collection
        .where('staffId', isEqualTo: staffId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TaskAssignment.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  // Lấy tất cả tasks
  Future<List<TaskAssignment>> getAllTasks() async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return TaskAssignment.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Lấy một task theo ID
  Future<TaskAssignment?> getTaskById(String taskId) async {
    final doc = await _collection.doc(taskId).get();
    if (!doc.exists) return null;
    return TaskAssignment.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ============================================
  // CẬP NHẬT TASK STATUS + AUTO UPDATE RECEPTION
  // ============================================
  Future<void> updateTaskStatus(String taskId, String status) async {
    // 1. Cập nhật task
    final updateData = <String, dynamic>{'status': status};

    if (status == 'in_progress') {
      updateData['startTime'] = DateTime.now().toIso8601String();
    } else if (status == 'done') {
      updateData['endTime'] = DateTime.now().toIso8601String();
    }

    await _collection.doc(taskId).update(updateData);

    // 2. Lấy thông tin task để biết receptionId
    final taskDoc = await _collection.doc(taskId).get();
    if (!taskDoc.exists) return;

    final task = TaskAssignment.fromMap(taskDoc.data() as Map<String, dynamic>);

    // 3. Tự động cập nhật trạng thái reception
    await _autoUpdateReceptionStatus(task.receptionId);
  }

  // ============================================
  // TỰ ĐỘNG CẬP NHẬT TRẠNG THÁI RECEPTION
  // ============================================
  Future<void> _autoUpdateReceptionStatus(String receptionId) async {
    // Lấy tất cả tasks của reception này
    final tasksSnapshot = await _collection
        .where('receptionId', isEqualTo: receptionId)
        .get();

    if (tasksSnapshot.docs.isEmpty) return;

    final tasks = tasksSnapshot.docs.map((doc) {
      return TaskAssignment.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    // Đếm số lượng tasks theo status
    int inProgressCount = tasks.where((t) => t.status == 'in_progress').length;
    int doneCount = tasks.where((t) => t.status == 'done').length;

    String newReceptionStatus;

    // LOGIC QUY ƯỚC:
    if (doneCount == tasks.length) {
      // TẤT CẢ tasks đã done → Reception done
      newReceptionStatus = 'done';
    } else if (inProgressCount > 0 || doneCount > 0) {
      // CÓ ÍT NHẤT 1 task in_progress hoặc done → Reception in_progress
      newReceptionStatus = 'in_progress';
    } else {
      // TẤT CẢ tasks pending → Reception pending
      newReceptionStatus = 'pending';
    }

    // Cập nhật reception
    await _receptionsCollection.doc(receptionId).update({
      'status': newReceptionStatus,
    });

    // Nếu reception vừa chuyển sang DONE → Tạo doanh thu
    if (newReceptionStatus == 'done') {
      await _createRevenueFromReception(receptionId);
    }
  }

  // ============================================
  // TẠO DOANH THU TỪ RECEPTION
  // ============================================
  Future<void> _createRevenueFromReception(String receptionId) async {
    try {
      // Kiểm tra xem đã tạo revenue cho reception này chưa
      final existingRevenue = await _revenuesCollection
          .where('receptionId', isEqualTo: receptionId)
          .limit(1)
          .get();

      if (existingRevenue.docs.isNotEmpty) {
        // Đã có revenue rồi, không tạo nữa
        return;
      }

      // Lấy thông tin reception
      final receptionDoc = await _receptionsCollection.doc(receptionId).get();
      if (!receptionDoc.exists) {
        return;
      }

      final receptionData = receptionDoc.data() as Map<String, dynamic>;

      // Tạo revenue
      final revenueId = _uuid.v4();
      final now = DateTime.now();

      // ✅ SỬA: Parse createdAt đúng cách
      DateTime createdAt;
      if (receptionData['createdAt'] is Timestamp) {
        createdAt = (receptionData['createdAt'] as Timestamp).toDate();
      } else if (receptionData['createdAt'] is String) {
        createdAt = DateTime.parse(receptionData['createdAt']);
      } else {
        createdAt = now;
      }

      final revenueData = {
        'id': revenueId,
        'receptionId': receptionId,
        'customerId': receptionData['customerId'] ?? '',
        'vehicleId': receptionData['vehicleId'] ?? '',
        'totalPrice': (receptionData['totalPrice'] as num?)?.toDouble() ?? 0.0,
        'serviceIds': List<String>.from(receptionData['serviceIds'] ?? []),
        'staffIds': List<String>.from(receptionData['staffIds'] ?? []),
        'createdAt': createdAt.toIso8601String(),
        'completedAt': now.toIso8601String(),
      };

      await _revenuesCollection.doc(revenueId).set(revenueData);
    } catch (e) {
      // Log error nhưng không throw để không làm crash app
      // Trong production nên log vào service như Sentry
      rethrow;
    }
  }

  // Cập nhật toàn bộ task
  Future<void> updateTask(TaskAssignment task) async {
    await _collection.doc(task.id).update(task.toMap());
    // Cập nhật reception status
    await _autoUpdateReceptionStatus(task.receptionId);
  }

  // Xóa một task
  Future<void> deleteTask(String taskId) async {
    final taskDoc = await _collection.doc(taskId).get();
    if (!taskDoc.exists) return;

    final task = TaskAssignment.fromMap(taskDoc.data() as Map<String, dynamic>);
    final receptionId = task.receptionId;

    await _collection.doc(taskId).delete();

    // Cập nhật lại reception status
    await _autoUpdateReceptionStatus(receptionId);
  }

  // Xóa tất cả tasks của một reception
  Future<void> deleteTasksByReception(String receptionId) async {
    final snapshot = await _collection
        .where('receptionId', isEqualTo: receptionId)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Đếm tasks theo status
  Future<Map<String, int>> getTaskCountByStatus() async {
    final snapshot = await _collection.get();

    final counts = <String, int>{'pending': 0, 'in_progress': 0, 'done': 0};

    for (var doc in snapshot.docs) {
      final task = TaskAssignment.fromMap(doc.data() as Map<String, dynamic>);
      counts[task.status] = (counts[task.status] ?? 0) + 1;
    }

    return counts;
  }

  // Đếm tasks của một staff theo status
  Future<Map<String, int>> getStaffTaskCountByStatus(String staffId) async {
    final snapshot = await _collection
        .where('staffId', isEqualTo: staffId)
        .get();

    final counts = <String, int>{'pending': 0, 'in_progress': 0, 'done': 0};

    for (var doc in snapshot.docs) {
      final task = TaskAssignment.fromMap(doc.data() as Map<String, dynamic>);
      counts[task.status] = (counts[task.status] ?? 0) + 1;
    }

    return counts;
  }
}
