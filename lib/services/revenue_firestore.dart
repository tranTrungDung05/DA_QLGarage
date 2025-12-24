// File: lib/services/revenue_firestore.dart
// Service quản lý doanh thu

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/revenue.dart';

class RevenueFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('revenues');

  // Stream tất cả revenues - Realtime
  Stream<List<Revenue>> getRevenues() {
    return _collection.orderBy('completedAt', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return Revenue.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      },
    );
  }

  // Get tất cả revenues - One-time
  Future<List<Revenue>> getAllRevenues() async {
    final snapshot = await _collection
        .orderBy('completedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      return Revenue.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Get revenues theo khoảng thời gian
  Future<List<Revenue>> getRevenuesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _collection
        .where(
          'completedAt',
          isGreaterThanOrEqualTo: startDate.toIso8601String(),
        )
        .where('completedAt', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Revenue.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Tính tổng doanh thu
  Future<double> getTotalRevenue() async {
    final revenues = await getAllRevenues();
    double total = 0.0;
    for (var revenue in revenues) {
      total += revenue.totalPrice;
    }
    return total;
  }

  // Tính doanh thu theo tháng
  Future<Map<String, double>> getRevenueByMonth(int year) async {
    final revenues = await getAllRevenues();
    final monthlyRevenue = <String, double>{};

    for (var revenue in revenues) {
      if (revenue.completedAt.year == year) {
        final monthKey =
            '${revenue.completedAt.year}-${revenue.completedAt.month.toString().padLeft(2, '0')}';
        monthlyRevenue[monthKey] =
            (monthlyRevenue[monthKey] ?? 0) + revenue.totalPrice;
      }
    }

    return monthlyRevenue;
  }

  // Tính doanh thu hôm nay
  Future<double> getTodayRevenue() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final revenues = await getRevenuesByDateRange(startOfDay, endOfDay);
    double total = 0.0;
    for (var revenue in revenues) {
      total += revenue.totalPrice;
    }
    return total;
  }

  // Tính doanh thu tháng này
  Future<double> getThisMonthRevenue() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final revenues = await getRevenuesByDateRange(startOfMonth, endOfMonth);
    double total = 0.0;
    for (var revenue in revenues) {
      total += revenue.totalPrice;
    }
    return total;
  }

  // Tính doanh thu năm nay
  Future<double> getThisYearRevenue() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

    final revenues = await getRevenuesByDateRange(startOfYear, endOfYear);
    double total = 0.0;
    for (var revenue in revenues) {
      total += revenue.totalPrice;
    }
    return total;
  }

  // Get revenue theo reception ID
  Future<Revenue?> getRevenueByReceptionId(String receptionId) async {
    final snapshot = await _collection
        .where('receptionId', isEqualTo: receptionId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return Revenue.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
  }

  // Xóa revenue
  Future<void> deleteRevenue(String revenueId) async {
    await _collection.doc(revenueId).delete();
  }

  // Thống kê tổng quan
  Future<Map<String, dynamic>> getRevenueStats() async {
    final revenues = await getAllRevenues();

    double total = 0.0;
    for (var r in revenues) {
      total += r.totalPrice;
    }

    return {
      'total': total,
      'count': revenues.length,
      'today': await getTodayRevenue(),
      'thisMonth': await getThisMonthRevenue(),
      'thisYear': await getThisYearRevenue(),
      'average': revenues.isEmpty ? 0.0 : total / revenues.length,
    };
  }
}
