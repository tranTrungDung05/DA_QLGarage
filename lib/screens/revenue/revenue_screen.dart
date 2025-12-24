// File: lib/screens/revenue/revenue_screen.dart
// Màn hình hiển thị báo cáo doanh thu

import 'package:flutter/material.dart';
import 'package:flutter_application/models/revenue.dart';
import 'package:flutter_application/services/revenue_firestore.dart';

class RevenueScreen extends StatelessWidget {
  final RevenueFirestore firestore;

  const RevenueScreen({super.key, required this.firestore});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Revenue>>(
      stream: firestore.getRevenues(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.money_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có dữ liệu doanh thu',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final revenues = snapshot.data!;
        final totalRevenue = revenues.fold(
          0.0,
          (sum, revenue) => sum + revenue.totalPrice,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalRevenueCard(totalRevenue, revenues.length),
              const SizedBox(height: 16),
              _buildStatsCards(revenues),
              const SizedBox(height: 16),
              _buildRevenueList(revenues),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalRevenueCard(double total, int count) {
    return Card(
      color: Colors.green.shade50,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '💰 Tổng Doanh Thu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _formatMoney(total),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Từ $count phiếu tiếp nhận',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(List<Revenue> revenues) {
    // Tính doanh thu hôm nay
    final now = DateTime.now();
    final today = revenues.where((r) {
      return r.completedAt.year == now.year &&
          r.completedAt.month == now.month &&
          r.completedAt.day == now.day;
    }).toList();

    final todayTotal = today.fold(0.0, (sum, r) => sum + r.totalPrice);

    // Tính doanh thu tháng này
    final thisMonth = revenues.where((r) {
      return r.completedAt.year == now.year && r.completedAt.month == now.month;
    }).toList();

    final monthTotal = thisMonth.fold(0.0, (sum, r) => sum + r.totalPrice);

    // Trung bình
    final average = revenues.isEmpty
        ? 0.0
        : revenues.fold(0.0, (sum, r) => sum + r.totalPrice) / revenues.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '📅 Hôm nay',
            _formatMoney(todayTotal),
            '${today.length} phiếu',
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            '📆 Tháng này',
            _formatMoney(monthTotal),
            '${thisMonth.length} phiếu',
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            '📊 Trung bình',
            _formatMoney(average),
            'mỗi phiếu',
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueList(List<Revenue> revenues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋 Danh sách doanh thu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: revenues.length,
          itemBuilder: (context, index) {
            final revenue = revenues[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  _formatMoney(revenue.totalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('📅 ${_formatDate(revenue.completedAt)}'),
                    Text('⏱️ Hoàn thành trong: ${revenue.durationText}'),
                    Text('🔧 ${revenue.serviceIds.length} dịch vụ'),
                    Text('👨‍🔧 ${revenue.staffIds.length} nhân viên'),
                  ],
                ),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatMoney(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')} VNĐ';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
