// File: lib/screens/staff/staff_list_screen.dart
// Màn hình hiển thị danh sách nhân viên (đơn giản)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/staff.dart';
import '../../services/staff_firestore.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = StaffFirestore();

    return StreamBuilder<List<Staff>>(
      stream: firestore.getEmployees(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Chưa có dữ liệu
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có nhân viên',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/staff_form'),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm nhân viên'),
                ),
              ],
            ),
          );
        }

        // Có dữ liệu → Hiển thị danh sách
        final employees = snapshot.data!;

        return ListView.builder(
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final emp = employees[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                // Avatar
                leading: CircleAvatar(
                  child: Text(emp.name.isNotEmpty ? emp.name[0] : '?'),
                ),

                // Tên
                title: Text(
                  emp.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                // Vị trí và lương
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🔧 ${emp.positionName}'),
                    Text(
                      '💰 ${_formatMoney(emp.salary)}',
                      style: const TextStyle(color: Colors.green),
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
                        context.push('/staff_form', extra: emp);
                      },
                    ),
                    // Nút Xóa
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteDialog(context, firestore, emp);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Dialog xác nhận xóa
  void _showDeleteDialog(
    BuildContext context,
    StaffFirestore firestore,
    Staff emp,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa nhân viên "${emp.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await firestore.deleteEmployee(emp.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa nhân viên')),
                );
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
