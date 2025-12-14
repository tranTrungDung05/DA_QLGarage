import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/vehicle.dart';
import 'package:flutter_application/services/vehicle_firestore.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = VehicleFirestore();

    return StreamBuilder<List<Vehicle>>(
      stream: firestore.getVehicles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có phương tiện'));
        }

        final vehicles = snapshot.data!;

        return ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final v = vehicles[index];
            return ListTile(
              title: Text('${v.brand} ${v.model}'),
              subtitle: Text(v.plateNumber),
              onTap: () => context.push('/vehicle_form', extra: v),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => firestore.deleteVehicle(v.id),
              ),
            );
          },
        );
      },
    );
  }
}
