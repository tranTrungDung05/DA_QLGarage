import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/vehicle.dart';
import 'package:flutter_application/services/vehicle_firestore.dart';
import 'package:flutter_application/services/customer_firestore.dart';
import 'package:uuid/uuid.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;
  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();

  final firestore = VehicleFirestore();
  final customerFirestore = CustomerFirestore();
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    if (v != null) {
      _brandCtrl.text = v.brand;
      _modelCtrl.text = v.model;
      _yearCtrl.text = v.year.toString();
      _plateCtrl.text = v.plateNumber;
      _colorCtrl.text = v.color ?? '';
      _ownerPhoneCtrl.text = v.ownerPhoneNumber ?? '';
    }
  }

  Future<void> _save() async {
    final id = widget.vehicle?.id ?? uuid.v4();
    String? customerId = widget.vehicle?.customerId;
    if (_ownerPhoneCtrl.text.isNotEmpty && customerId == null) {
      final customer = await customerFirestore.getCustomerByPhoneNumber(
        _ownerPhoneCtrl.text,
      );
      if (customer != null) {
        customerId = customer.id;
      }
    }
    final vehicle = Vehicle(
      id: id,
      brand: _brandCtrl.text,
      model: _modelCtrl.text,
      year: int.tryParse(_yearCtrl.text) ?? 0,
      plateNumber: _plateCtrl.text,
      color: _colorCtrl.text.isEmpty ? null : _colorCtrl.text,
      ownerPhoneNumber: _ownerPhoneCtrl.text.isEmpty
          ? null
          : _ownerPhoneCtrl.text,
      customerId: customerId,
    );

    if (widget.vehicle == null) {
      await firestore.addVehicle(vehicle);
    } else {
      await firestore.updateVehicle(vehicle);
    }

    if (!mounted) return;
    context.pop();
  }

  Future<void> _saveAndContinue() async {
    final id = widget.vehicle?.id ?? uuid.v4();
    String? customerId = widget.vehicle?.customerId;
    if (_ownerPhoneCtrl.text.isNotEmpty && customerId == null) {
      final customer = await customerFirestore.getCustomerByPhoneNumber(
        _ownerPhoneCtrl.text,
      );
      if (customer != null) {
        customerId = customer.id;
      }
    }
    final vehicle = Vehicle(
      id: id,
      brand: _brandCtrl.text,
      model: _modelCtrl.text,
      year: int.tryParse(_yearCtrl.text) ?? 0,
      plateNumber: _plateCtrl.text,
      color: _colorCtrl.text.isEmpty ? null : _colorCtrl.text,
      ownerPhoneNumber: _ownerPhoneCtrl.text.isEmpty
          ? null
          : _ownerPhoneCtrl.text,
      customerId: customerId,
    );

    if (widget.vehicle == null) {
      await firestore.addVehicle(vehicle);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu')));
      _brandCtrl.clear();
      _modelCtrl.clear();
      _yearCtrl.clear();
      _plateCtrl.clear();
      _colorCtrl.clear();
      _ownerPhoneCtrl.clear();
    } else {
      await firestore.updateVehicle(vehicle);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.vehicle != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa phương tiện' : 'Thêm phương tiện'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _brandCtrl,
              decoration: const InputDecoration(labelText: 'Hãng'),
            ),
            TextField(
              controller: _modelCtrl,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
            TextField(
              controller: _yearCtrl,
              decoration: const InputDecoration(labelText: 'Năm'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _plateCtrl,
              decoration: const InputDecoration(labelText: 'Biển số'),
            ),
            TextField(
              controller: _colorCtrl,
              decoration: const InputDecoration(labelText: 'Màu'),
            ),
            TextField(
              controller: _ownerPhoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại chủ xe',
              ),
            ),
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
