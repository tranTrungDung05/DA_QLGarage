import 'package:flutter/material.dart';
import 'package:flutter_application/models/service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/services/service_firestore.dart';
import 'package:uuid/uuid.dart';

class ServiceFormScreen extends StatefulWidget {
  final Service? service;

  const ServiceFormScreen({super.key, this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();

  final firestore = ServiceFirestore();
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();

    final s = widget.service;
    if (s != null) {
      _nameCtrl.text = s.name;
      _descCtrl.text = s.description;
      _priceCtrl.text = s.price.toString();
      _durationCtrl.text = s.durationInMinutes?.toString() ?? '';
    }
  }

  void _save() async {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final duration = int.tryParse(_durationCtrl.text);

    if (widget.service == null) {
      final service = Service(
        id: uuid.v4(),
        name: _nameCtrl.text,
        description: _descCtrl.text,
        price: price,
        durationInMinutes: duration,
      );

      await firestore.addService(service);
    } else {
      final updated = Service(
        id: widget.service!.id,
        name: _nameCtrl.text,
        description: _descCtrl.text,
        price: price,
        durationInMinutes: duration,
      );

      await firestore.updateService(updated);
    }

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.service != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa dịch vụ' : 'Thêm dịch vụ')),
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Tên dịch vụ'),
            ),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            TextField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: 'Giá'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _durationCtrl,
              decoration: const InputDecoration(labelText: 'Thời gian (phút)'),
              keyboardType: TextInputType.number,
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

  void _saveAndContinue() async {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final duration = int.tryParse(_durationCtrl.text);

    if (widget.service == null) {
      final service = Service(
        id: uuid.v4(),
        name: _nameCtrl.text,
        description: _descCtrl.text,
        price: price,
        durationInMinutes: duration,
      );

      await firestore.addService(service);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu')));

      // Clear form for next entry
      _nameCtrl.clear();
      _descCtrl.clear();
      _priceCtrl.clear();
      _durationCtrl.clear();
    } else {
      final updated = Service(
        id: widget.service!.id,
        name: _nameCtrl.text,
        description: _descCtrl.text,
        price: price,
        durationInMinutes: duration,
      );

      await firestore.updateService(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật')));
    }
  }
}
