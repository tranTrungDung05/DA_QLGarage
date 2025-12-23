import 'package:flutter/material.dart';
import 'package:flutter_application/models/customer.dart';
import 'package:flutter_application/models/vehicle.dart';
import 'package:flutter_application/services/customer_firestore.dart';
import 'package:flutter_application/services/vehicle_firestore.dart';
import 'package:uuid/uuid.dart';

class CustomerFormController extends ChangeNotifier {
  // Text Controllers
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final plateNumberCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final colorCtrl = TextEditingController();

  // Services
  final firestore = CustomerFirestore();
  final vehicleFirestore = VehicleFirestore();
  final uuid = const Uuid();

  // State
  bool _addVehicle = false;
  bool get addVehicle => _addVehicle;

  Customer? _customer;
  bool get isEdit => _customer != null;

  // Constructor
  CustomerFormController({Customer? customer}) {
    _customer = customer;
    if (customer != null) {
      _initializeWithCustomer(customer);
    }
  }

  void _initializeWithCustomer(Customer customer) {
    nameCtrl.text = customer.name;
    phoneCtrl.text = customer.phoneNumber;
    emailCtrl.text = customer.email ?? '';
    addressCtrl.text = customer.address ?? '';
  }

  void toggleAddVehicle(bool? value) {
    _addVehicle = value ?? false;
    notifyListeners();
  }

  Customer _buildCustomer() {
    final id = _customer?.id ?? uuid.v4();
    return Customer(
      id: id,
      phoneNumber: phoneCtrl.text,
      name: nameCtrl.text,
      email: emailCtrl.text.isEmpty ? null : emailCtrl.text,
      address: addressCtrl.text.isEmpty ? null : addressCtrl.text,
    );
  }

  Future<void> save() async {
    final customer = _buildCustomer();

    if (_customer == null) {
      await firestore.addCustomer(customer);
    } else {
      await firestore.updateCustomer(customer);
    }

    if (_addVehicle) {
      await _createVehicleForCustomer(customer);
    }
  }

  Future<void> saveAndContinue() async {
    final customer = _buildCustomer();

    if (_customer == null) {
      await firestore.addCustomer(customer);
    } else {
      await firestore.updateCustomer(customer);
    }

    if (_addVehicle) {
      await _createVehicleForCustomer(customer);
    }

    // Clear form if creating new customer
    if (_customer == null) {
      clearForm();
    }
  }

  void clearForm() {
    nameCtrl.clear();
    phoneCtrl.clear();
    emailCtrl.clear();
    addressCtrl.clear();
    plateNumberCtrl.clear();
    brandCtrl.clear();
    modelCtrl.clear();
    yearCtrl.clear();
    colorCtrl.clear();
    _addVehicle = false;
    notifyListeners();
  }

  Future<void> _createVehicleForCustomer(Customer customer) async {
    if (plateNumberCtrl.text.isNotEmpty && brandCtrl.text.isNotEmpty) {
      final existingVehicle = await vehicleFirestore.getVehicleByPlateNumber(
        plateNumberCtrl.text,
      );

      if (existingVehicle == null) {
        final vehicleId = uuid.v4();
        final vehicle = Vehicle(
          id: vehicleId,
          brand: brandCtrl.text,
          model: modelCtrl.text,
          year: int.tryParse(yearCtrl.text) ?? 0,
          plateNumber: plateNumberCtrl.text,
          color: colorCtrl.text.isEmpty ? null : colorCtrl.text,
          ownerPhoneNumber: customer.phoneNumber,
          customerId: customer.id,
        );
        await vehicleFirestore.addVehicle(vehicle);
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    plateNumberCtrl.dispose();
    brandCtrl.dispose();
    modelCtrl.dispose();
    yearCtrl.dispose();
    colorCtrl.dispose();
    super.dispose();
  }
}
