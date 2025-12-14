import 'package:flutter/material.dart';
import 'package:flutter_application/models/staff.dart';
import 'package:flutter_application/services/staff_firestore.dart';
import 'package:go_router/go_router.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = StaffFirestore();

    return StreamBuilder<List<Staff>>(
      stream: firestore.getEmployees(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có nhân viên'));
        }

        final employees = snapshot.data!;

        return ListView.builder(
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final emp = employees[index];

            return ListTile(
              title: Text(emp.name),
              subtitle: Text(emp.position),
              onTap: () => context.push('/staff_form', extra: emp),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  firestore.deleteEmployee(emp.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}
