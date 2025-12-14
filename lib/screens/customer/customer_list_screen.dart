import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/customer.dart';
import '../../services/customer_firestore.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = CustomerFirestore();

    return StreamBuilder<List<Customer>>(
      stream: firestore.streamCustomers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có khách hàng'));
        }

        final customers = snapshot.data!;

        return ListView.builder(
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final c = customers[index];
            return ListTile(
              title: Text(c.name),
              subtitle: Text(c.phoneNumber),
              onTap: () => context.push('/customer_form', extra: c),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => firestore.deleteCustomer(c.id),
              ),
            );
          },
        );
      },
    );
  }
}
