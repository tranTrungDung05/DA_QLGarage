import 'package:flutter/material.dart';
import 'package:flutter_application/screens/services/service_list_screen.dart';
import 'package:flutter_application/screens/staff/staff_list_screen.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text('Trang tổng quan')),
    ServiceListScreen(),
    StaffListScreen(),
    Center(child: Text('Doanh thu')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
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
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          _currentIndex == 1
              ? 'Dịch vụ'
              : (_currentIndex == 2 ? 'Nhân viên' : 'Garage'),
        ),
      ),
      body: _pages[_currentIndex],
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
            backgroundColor: Color.fromARGB(255, 120, 247, 173),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Dịch vụ',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Nhân viên',
            backgroundColor: Color.fromARGB(255, 181, 78, 245),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Doanh thu',
          ),
        ],
      ),
    );
  }
}
