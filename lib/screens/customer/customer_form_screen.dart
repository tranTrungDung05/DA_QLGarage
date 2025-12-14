import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/customer.dart';
import 'package:flutter_application/services/customer_firestore.dart';
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

  final firestore = CustomerFirestore();
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu')));
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _emailCtrl.clear();
      _addressCtrl.clear();
    } else {
      await firestore.updateCustomer(customer);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật')));
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
