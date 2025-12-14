import 'package:flutter/material.dart';
import 'package:flutter_application/screens/auth/login_screen.dart';
import 'package:flutter_application/screens/auth/register_screen.dart';
import 'package:flutter_application/screens/dashboard_screens/dashboard_screen.dart';
import 'package:flutter_application/screens/services/service_form_screen.dart';
import 'package:flutter_application/screens/staff/staff_form_screen.dart';
import 'package:flutter_application/screens/customer/customer_form_screen.dart';
import 'package:flutter_application/screens/vehicle/vehicle_form_screen.dart';
import 'package:flutter_application/screens/customer/customer_list_screen.dart';
import 'package:flutter_application/screens/vehicle/vehicle_list_screen.dart';
import 'package:flutter_application/models/customer.dart';
import 'package:flutter_application/models/vehicle.dart';
import 'package:flutter_application/models/service.dart';
import 'package:flutter_application/models/staff.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/service_form',
        builder: (context, state) =>
            ServiceFormScreen(service: state.extra as Service?),
      ),
      GoRoute(
        path: '/staff_form',
        builder: (context, state) =>
            StaffFormScreen(staff: state.extra as Staff?),
      ),
      GoRoute(
        path: '/customer_form',
        builder: (context, state) =>
            CustomerFormScreen(customer: state.extra as Customer?),
      ),
      GoRoute(
        path: '/vehicle_form',
        builder: (context, state) =>
            VehicleFormScreen(vehicle: state.extra as Vehicle?),
      ),
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
    ],
  );
}
