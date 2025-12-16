import 'package:flutter/material.dart';
import 'package:flutter_application/models/reception.dart';
import 'package:flutter_application/services/reception_firestore.dart';
import 'package:go_router/go_router.dart';

// Màn hình hiển thị danh sách các phiếu tiếp nhận
class ReceptionListScreen extends StatelessWidget {
  // Dịch vụ để lấy dữ liệu từ Firestore
  final firestore = ReceptionFirestore();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Reception>>(
      // Lắng nghe thay đổi từ Firestore
      stream: firestore.getReceptions(),
      builder: (context, snapshot) {
        // Hiển thị loading nếu đang kết nối
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Hiển thị lỗi nếu có
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        // Nếu không có dữ liệu
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có phiếu tiếp nhận nào.'));
        }

        // Lấy danh sách receptions
        final receptions = snapshot.data!;

        // Hiển thị danh sách bằng ListView
        return ListView.builder(
          itemCount: receptions.length,
          itemBuilder: (context, index) {
            final r = receptions[index];

            // Mỗi item hiển thị ID ngắn, status và tổng tiền
            return ListTile(
              title: Text('Phiếu #${r.id.substring(0, 6)}'),
              subtitle: Text('${r.status.toUpperCase()} - ${r.totalPrice} VND'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(label: Text(r.status)),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.push('/reception_form', extra: r),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteReception(context, r.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Hàm xóa reception
  void _deleteReception(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa phiếu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await firestore.deleteReception(id);
              Navigator.of(context).pop();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
