import 'package:flutter/material.dart';
import 'package:flutter_application/screens/services/service_list_screen.dart';
import 'package:flutter_application/screens/staff/staff_list_screen.dart';
import 'package:flutter_application/screens/revenue/revenue_screen.dart';
import 'package:flutter_application/models/reception.dart';
import 'package:flutter_application/services/reception_firestore.dart';
import 'package:flutter_application/services/revenue_firestore.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final ReceptionFirestore _receptionService = ReceptionFirestore();
  final RevenueFirestore _revenueService = RevenueFirestore();

  @override
  Widget build(BuildContext context) {
    // Danh sách các trang
    final List<Widget> pages = [
      _buildOverviewPage(), // Tab Tổng quan
      ServiceListScreen(),
      StaffListScreen(),
      RevenueScreen(firestore: _revenueService),
    ];

    final List<String> titles = [
      'Tổng quan',
      'Dịch vụ',
      'Nhân viên',
      'Doanh thu',
    ];

    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(title: Text(titles[_currentIndex])),
      body: pages[_currentIndex],
      floatingActionButton: (_currentIndex == 1 || _currentIndex == 2)
          ? FloatingActionButton(
              onPressed: () {
                if (_currentIndex == 1) {
                  context.push('/service_form');
                } else if (_currentIndex == 2) {
                  context.push('/staff_form');
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Dịch vụ'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Nhân viên'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Doanh thu',
          ),
        ],
      ),
    );
  }

  // ============================================
  // TAB TỔNG QUAN - NỘI DUNG CHÍNH
  // ============================================
  Widget _buildOverviewPage() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 20),
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildActiveReceptionsSection(),
            const SizedBox(height: 24),
            _buildWarningsSection(),
          ],
        ),
      ),
    );
  }

  // ============================================
  // WELCOME SECTION
  // ============================================
  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;

    if (hour < 12) {
      greeting = 'Chào buổi sáng';
      emoji = '🌅';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
      emoji = '☀️';
    } else {
      greeting = 'Chào buổi tối';
      emoji = '🌙';
    }

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(DateTime.now()),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // 4 CARDS THỐNG KÊ
  // ============================================
  Widget _buildStatsCards() {
    return StreamBuilder<List<Reception>>(
      stream: _receptionService.getReceptions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final receptions = snapshot.data!;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Khách hôm nay
        final todayReceptions = receptions.where((r) {
          final createdDate = DateTime(
            r.createdAt.year,
            r.createdAt.month,
            r.createdAt.day,
          );
          return createdDate.isAtSameMomentAs(today);
        }).length;

        // Xe trong xưởng
        final carsInShop = receptions
            .where((r) => r.status == 'pending' || r.status == 'in_progress')
            .length;

        // Đang xử lý
        final processing = receptions
            .where((r) => r.status == 'in_progress')
            .length;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.person_add,
                    label: 'Khách hôm nay',
                    value: todayReceptions.toString(),
                    color: Colors.blue,
                    onTap: () => context.push('/receptions'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.directions_car,
                    label: 'Xe trong xưởng',
                    value: carsInShop.toString(),
                    color: Colors.orange,
                    onTap: () => context.push('/receptions'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.build,
                    label: 'Đang xử lý',
                    value: processing.toString(),
                    color: Colors.purple,
                    onTap: () => context.push('/receptions'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<double>(
                    future: _revenueService.getTodayRevenue(),
                    builder: (context, snapshot) {
                      final revenue = snapshot.data ?? 0.0;
                      return _buildStatCard(
                        icon: Icons.attach_money,
                        label: 'Doanh thu hôm nay',
                        value: _formatMoneyShort(revenue),
                        color: Colors.green,
                        onTap: () => setState(() => _currentIndex = 3),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // XƯỞNG ĐANG LÀM GÌ?
  // ============================================
  Widget _buildActiveReceptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🔧 Xưởng đang làm gì?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.push('/receptions'),
              child: const Text('Xem tất cả →'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Reception>>(
          stream: _receptionService.getReceptions(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final active = snapshot.data!
                .where(
                  (r) => r.status == 'pending' || r.status == 'in_progress',
                )
                .take(5)
                .toList();

            if (active.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Không có công việc đang xử lý',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: active.length,
              itemBuilder: (context, index) =>
                  _buildReceptionCard(active[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReceptionCard(Reception r) {
    Color color;
    String status;
    IconData icon;

    switch (r.status) {
      case 'pending':
        color = Colors.orange;
        status = 'Đang chờ';
        icon = Icons.pending;
        break;
      case 'in_progress':
        color = Colors.blue;
        status = 'Đang làm';
        icon = Icons.build;
        break;
      default:
        color = Colors.green;
        status = 'Hoàn thành';
        icon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/task-assignments/${r.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phiếu #${r.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatDate(r.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.build, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${r.serviceIds.length} dịch vụ',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${r.staffIds.length} nhân viên',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  Text(
                    _formatMoney(r.totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // CẢNH BÁO
  // ============================================
  Widget _buildWarningsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚠️ Cảnh báo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Reception>>(
          stream: _receptionService.getReceptions(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            final receptions = snapshot.data!;
            final warnings = <Widget>[];

            // Phiếu chờ > 30 phút
            final longWaiting = receptions.where((r) {
              if (r.status != 'pending') return false;
              return DateTime.now().difference(r.createdAt).inMinutes > 30;
            }).length;

            if (longWaiting > 0) {
              warnings.add(
                _buildWarningCard(
                  icon: Icons.access_time,
                  color: Colors.orange,
                  title: 'Phiếu chờ lâu',
                  message: '$longWaiting phiếu chờ xử lý quá 30 phút',
                  onTap: () => context.push('/receptions'),
                ),
              );
            }

            // Xe sửa > 2 giờ
            final longProcessing = receptions.where((r) {
              if (r.status != 'in_progress') return false;
              return DateTime.now().difference(r.createdAt).inHours > 2;
            }).length;

            if (longProcessing > 0) {
              warnings.add(
                _buildWarningCard(
                  icon: Icons.warning,
                  color: Colors.red,
                  title: 'Xe quá thời gian dự kiến',
                  message: '$longProcessing xe đang sửa quá 2 giờ',
                  onTap: () => context.push('/receptions'),
                ),
              );
            }

            if (warnings.isEmpty) {
              return Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Mọi thứ đang hoạt động tốt!',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(children: warnings);
          },
        ),
      ],
    );
  }

  Widget _buildWarningCard({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: color.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // DRAWER
  // ============================================
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Khách hàng'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/customers');
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Phương tiện'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/vehicles');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Phiếu tiếp nhận'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/receptions');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Quản lý vị trí công việc'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/positions');
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Phân công công việc'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/task-assignments');
            },
          ),
        ],
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================
  String _formatDate(DateTime date) {
    final days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return '${days[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
  }

  String _formatMoney(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}tr';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '${amount.toStringAsFixed(0)}đ';
  }

  String _formatMoneyShort(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
