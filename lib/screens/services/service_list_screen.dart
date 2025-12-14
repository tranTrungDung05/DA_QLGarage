import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/service.dart';
import 'package:flutter_application/services/service_firestore.dart';

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = ServiceFirestore();

    return StreamBuilder<List<Service>>(
      stream: firestore.getServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có dịch vụ'));
        }

        final services = snapshot.data!;

        return ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];

            return ListTile(
              title: Text(service.name),
              subtitle: Text('${service.price} VND'),
              onTap: () => context.push('/service_form', extra: service),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  firestore.deleteService(service.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}
