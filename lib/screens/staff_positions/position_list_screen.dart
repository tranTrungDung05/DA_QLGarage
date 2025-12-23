// File: lib/screens/position/position_list_screen.dart
// Màn hình hiển thị danh sách vị trí công việc

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/position.dart';
import '../../services/position_firestore.dart';

class PositionListScreen extends StatelessWidget {
  const PositionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = PositionFirestore();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý vị trí'),
        actions: [
          // Nút thêm position mới
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/position_form');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Position>>(
        stream: firestore.getPositions(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error (có thể do Firebase chưa init)
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Không thể tải dữ liệu',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Firebase chưa được cấu hình cho nền tảng này',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/position_form');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm vị trí (local)'),
                  ),
                ],
              ),
            );
          }

          // Chưa có dữ liệu
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.work_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có vị trí nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/position_form');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm vị trí'),
                  ),
                ],
              ),
            );
          }

          // Có dữ liệu → Hiển thị danh sách
          final positions = snapshot.data!;

          return ListView.builder(
            itemCount: positions.length,
            itemBuilder: (context, index) {
              final position = positions[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  // Icon
                  leading: const CircleAvatar(child: Icon(Icons.work)),

                  // Tên vị trí
                  title: Text(
                    position.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Mô tả và lương
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (position.description != null)
                        Text(position.description!),
                      const SizedBox(height: 4),
                      if (position.baseSalary != null)
                        Text(
                          'Lương: ${_formatMoney(position.baseSalary!)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),

                  // Nút Sửa/Xóa
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút Sửa
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          context.push('/position_form', extra: position);
                        },
                      ),
                      // Nút Xóa
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteDialog(context, firestore, position);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Hiển thị dialog xác nhận xóa
  void _showDeleteDialog(
    BuildContext context,
    PositionFirestore firestore,
    Position position,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa vị trí "${position.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await firestore.deletePosition(position.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã xóa vị trí')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // Format tiền
  String _formatMoney(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')} VNĐ';
  }
}
