import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/customer.dart';
import 'package:flutter_application/models/vehicle.dart';
import 'package:flutter_application/services/customer_firestore.dart';
import 'package:flutter_application/services/vehicle_firestore.dart';
import 'package:uuid/uuid.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;
  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _plateNumberCtrl = TextEditingController();

  // Vehicle fields
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();

  bool _addVehicle = false;

  final firestore = CustomerFirestore();
  final vehicleFirestore = VehicleFirestore();
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    if (c != null) {
      _nameCtrl.text = c.name;
      _phoneCtrl.text = c.phoneNumber;
      _emailCtrl.text = c.email ?? '';
      _addressCtrl.text = c.address ?? '';
    }
  }

  Future<void> _save() async {
    final id = widget.customer?.id ?? uuid.v4();
    final customer = Customer(
      id: id,
      phoneNumber: _phoneCtrl.text,
      name: _nameCtrl.text,
      email: _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
      address: _addressCtrl.text.isEmpty ? null : _addressCtrl.text,
    );

    if (widget.customer == null) {
      await firestore.addCustomer(customer);
    } else {
      await firestore.updateCustomer(customer);
    }
    if (_addVehicle) {
      await _createVehicleForCustomer(customer);
    }

    if (!mounted) return;
    context.pop();
  }

  Future<void> _saveAndContinue() async {
    final id = widget.customer?.id ?? uuid.v4();
    final customer = Customer(
      id: id,
      phoneNumber: _phoneCtrl.text,
      name: _nameCtrl.text,
      email: _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
      address: _addressCtrl.text.isEmpty ? null : _addressCtrl.text,
    );

    if (widget.customer == null) {
      await firestore.addCustomer(customer);
    } else {
      await firestore.updateCustomer(customer);
    }
    if (_addVehicle) {
      await _createVehicleForCustomer(customer);
    }
    if (widget.customer == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu')));
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _emailCtrl.clear();
      _addressCtrl.clear();
      _plateNumberCtrl.clear();
      _brandCtrl.clear();
      _modelCtrl.clear();
      _yearCtrl.clear();
      _colorCtrl.clear();
      _addVehicle = false;
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật')));
    }
  }

  Future<void> _createVehicleForCustomer(Customer customer) async {
    if (_plateNumberCtrl.text.isNotEmpty && _brandCtrl.text.isNotEmpty) {
      final existingVehicle = await vehicleFirestore.getVehicleByPlateNumber(
        _plateNumberCtrl.text,
      );
      if (existingVehicle == null) {
        final vehicleId = uuid.v4();
        final vehicle = Vehicle(
          id: vehicleId,
          brand: _brandCtrl.text,
          model: _modelCtrl.text,
          year: int.tryParse(_yearCtrl.text) ?? 0,
          plateNumber: _plateNumberCtrl.text,
          color: _colorCtrl.text.isEmpty ? null : _colorCtrl.text,
          ownerPhoneNumber: customer.phoneNumber,
          customerId: customer.id,
        );
        await vehicleFirestore.addVehicle(vehicle);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa khách hàng' : 'Thêm khách hàng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Thêm xe cho khách hàng'),
              value: _addVehicle,
              onChanged: (value) {
                setState(() {
                  _addVehicle = value ?? false;
                });
              },
            ),
            if (_addVehicle) ...[
              TextField(
                controller: _brandCtrl,
                decoration: const InputDecoration(labelText: 'Hãng xe'),
              ),
              TextField(
                controller: _modelCtrl,
                decoration: const InputDecoration(labelText: 'Model xe'),
              ),
              TextField(
                controller: _yearCtrl,
                decoration: const InputDecoration(labelText: 'Năm sản xuất'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _plateNumberCtrl,
                decoration: const InputDecoration(labelText: 'Biển số xe'),
              ),
              TextField(
                controller: _colorCtrl,
                decoration: const InputDecoration(labelText: 'Màu xe'),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Lưu'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAndContinue,
                    child: const Text('Lưu & Thêm tiếp'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
