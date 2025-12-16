import 'package:flutter/material.dart';
import 'package:flutter_application/models/reception.dart';
import 'package:flutter_application/services/reception_firestore.dart';

// Màn hình hiển thị báo cáo doanh thu
class RevenueScreen extends StatelessWidget {
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
          return const Center(child: Text('Chưa có dữ liệu doanh thu.'));
        }

        // Lấy danh sách receptions
        final receptions = snapshot.data!;

        // Tính tổng doanh thu từ receptions có status 'done'
        double totalRevenue = 0.0;
        for (var reception in receptions) {
          if (reception.status == 'done') {
            totalRevenue += reception.totalPrice;
          }
        }

        // Hiển thị tổng doanh thu
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tổng Doanh Thu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                '${totalRevenue.toStringAsFixed(0)} VND',
                style: const TextStyle(fontSize: 48, color: Colors.green),
              ),
              const SizedBox(height: 20),
              Text(
                'Từ ${receptions.where((r) => r.status == 'done').length} phiếu tiếp nhận hoàn thành',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
