import 'package:flutter/material.dart';
import 'package:flutter_application/models/position.dart';
import 'package:flutter_application/screens/auth/login_screen.dart';
import 'package:flutter_application/screens/auth/register_screen.dart';
import 'package:flutter_application/screens/dashboard_screens/dashboard_screen.dart';
import 'package:flutter_application/screens/services/service_form_screen.dart';
import 'package:flutter_application/screens/staff/staff_form_screen.dart';
import 'package:flutter_application/screens/customer/customer_form_screen.dart';
import 'package:flutter_application/screens/staff_positions/position_form_screen.dart';
import 'screens/staff_positions/position_list_screen.dart';
import 'package:flutter_application/screens/vehicle/vehicle_form_screen.dart';
import 'package:flutter_application/screens/customer/customer_list_screen.dart';
import 'package:flutter_application/screens/vehicle/vehicle_list_screen.dart';
import 'package:flutter_application/screens/reception/reception_list_screen.dart';
import 'package:flutter_application/screens/reception/reception_form_screen.dart';
import 'package:flutter_application/models/customer.dart';
import 'package:flutter_application/models/vehicle.dart';
import 'package:flutter_application/models/service.dart';
import 'package:flutter_application/models/staff.dart';
import 'package:flutter_application/models/reception.dart';
import 'package:go_router/go_router.dart';

// This file sets up the navigation routes for the app.
// It uses GoRouter to define how users move between different screens.

// createRouter creates and returns a GoRouter instance with all the app's routes.
GoRouter createRouter() {
  return GoRouter(
    // The first screen users see when the app starts.
    initialLocation: '/login',
    // List of all the routes in the app.
    routes: [
      // Route for the login screen.
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // Route for the register screen.
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Route for the main dashboard screen.
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      // Route for adding or editing a service.
      // It passes a Service object if editing, or null if adding new.
      GoRoute(
        path: '/service_form',
        builder: (context, state) =>
            ServiceFormScreen(service: state.extra as Service?),
      ),
      // Route for adding or editing staff.
      GoRoute(
        path: '/staff_form',
        builder: (context, state) =>
            StaffFormScreen(staff: state.extra as Staff?),
      ),
      // Route for adding or editing a customer.
      GoRoute(
        path: '/customer_form',
        builder: (context, state) =>
            CustomerFormScreen(customer: state.extra as Customer?),
      ),
      // Route for adding or editing a vehicle.
      GoRoute(
        path: '/vehicle_form',
        builder: (context, state) =>
            VehicleFormScreen(vehicle: state.extra as Vehicle?),
      ),
      // Route for the list of customers.
      // It includes a floating action button to add a new customer.
      GoRoute(
        path: '/customers',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Khách hàng')),
          body: const CustomerListScreen(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/customer_form'),
            child: const Icon(Icons.add),
          ),
        ),
      ),
      // Route for the list of vehicles.
      // It includes a floating action button to add a new vehicle.
      GoRoute(
        path: '/vehicles',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Phương tiện')),
          body: const VehicleListScreen(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/vehicle_form'),
            child: const Icon(Icons.add),
          ),
        ),
      ),
      // Route for the list of receptions.
      GoRoute(
        path: '/receptions',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Phiếu tiếp nhận')),
          body: ReceptionListScreen(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/reception_form'),
            child: const Icon(Icons.add),
          ),
        ),
      ), // Route for adding or editing a reception.
      GoRoute(
        path: '/reception_form',
        builder: (context, state) =>
            ReceptionFormScreen(reception: state.extra as Reception?),
      ),
      GoRoute(
        path: '/positions',
        builder: (context, state) => const PositionListScreen(),
      ),
      GoRoute(
        path: '/position_form',
        builder: (context, state) {
          final position = state.extra as Position?;
          return PositionFormScreen(position: position);
        },
      ),
    ],
  );
}
