// File: lib/screens/task_assignment/task_assignment_list_screen.dart
// Màn hình danh sách phân công công việc

import 'package:flutter/material.dart';
import 'package:flutter_application/models/task_assignment.dart';
import 'package:flutter_application/services/task_assignment_firestore.dart';

class TaskAssignmentListScreen extends StatefulWidget {
  final String? receptionId;
  final String? staffId;

  const TaskAssignmentListScreen({super.key, this.receptionId, this.staffId});

  @override
  State<TaskAssignmentListScreen> createState() =>
      _TaskAssignmentListScreenState();
}

class _TaskAssignmentListScreenState extends State<TaskAssignmentListScreen> {
  final TaskAssignmentFirestore _firestore = TaskAssignmentFirestore();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Chọn stream phù hợp
    Stream<List<TaskAssignment>> stream;
    String title;

    if (widget.receptionId != null) {
      stream = _firestore.getTasksByReception(widget.receptionId!);
      title = 'Phân công công việc';
    } else if (widget.staffId != null) {
      stream = _firestore.getTasksByStaff(widget.staffId!);
      title = 'Công việc của tôi';
    } else {
      // Không support stream cho tất cả, dùng future
      return _buildAllTasksScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: StreamBuilder<List<TaskAssignment>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.receptionId != null
                        ? 'Chưa có phân công nào'
                        : 'Bạn chưa có công việc nào',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              // Force rebuild bằng cách setState
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskCard(task);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(TaskAssignment task) {
    // Màu theo status
    Color statusColor;
    IconData statusIcon;

    switch (task.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle;
        break;
      case 'done':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(statusIcon, color: Colors.white),
        ),
        title: Text(
          task.serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(task.staffName),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                task.statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            if (task.startTime != null || task.endTime != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task.duration,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            if (task.status != 'in_progress')
              const PopupMenuItem(
                value: 'in_progress',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Bắt đầu'),
                  ],
                ),
              ),
            if (task.status != 'done')
              const PopupMenuItem(
                value: 'done',
                child: Row(
                  children: [
                    Icon(Icons.check, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Hoàn thành'),
                  ],
                ),
              ),
            if (task.status != 'pending')
              const PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Đặt lại'),
                  ],
                ),
              ),
          ],
          onSelected: (value) => _updateTaskStatus(task, value),
        ),
      ),
    );
  }

  Future<void> _updateTaskStatus(TaskAssignment task, String newStatus) async {
    // Hiển thị loading
    setState(() => _isLoading = true);

    try {
      await _firestore.updateTaskStatus(task.id, newStatus);

      if (!mounted) return;

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                newStatus == 'done'
                    ? Icons.check_circle
                    : newStatus == 'in_progress'
                    ? Icons.play_circle
                    : Icons.refresh,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đã cập nhật: ${task.serviceName} → ${_getStatusText(newStatus)}',
                ),
              ),
            ],
          ),
          backgroundColor: newStatus == 'done'
              ? Colors.green
              : newStatus == 'in_progress'
              ? Colors.blue
              : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Hiển thị lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Lỗi: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getStatusText(String status) {
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

  Widget _buildAllTasksScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: FutureBuilder<List<TaskAssignment>>(
        future: _firestore.getAllTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có công việc nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Làm mới'),
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data!;

          // Thống kê
          final pendingCount = tasks.where((t) => t.status == 'pending').length;
          final inProgressCount = tasks
              .where((t) => t.status == 'in_progress')
              .length;
          final doneCount = tasks.where((t) => t.status == 'done').length;

          return Column(
            children: [
              // Stats cards
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '⏳ Chờ',
                        pendingCount,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        '🔧 Đang làm',
                        inProgressCount,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard('✅ Xong', doneCount, Colors.green),
                    ),
                  ],
                ),
              ),
              // Task list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(tasks[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
