import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/staff.dart';
import 'package:flutter_application/services/staff_firestore.dart';
import 'package:uuid/uuid.dart';

class StaffFormScreen extends StatefulWidget {
  final Staff? staff;

  const StaffFormScreen({super.key, this.staff});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  final _nameCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();

  final firestore = StaffFirestore();
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();

    final s = widget.staff;
    if (s != null) {
      _nameCtrl.text = s.name;
      _positionCtrl.text = s.position;
      _salaryCtrl.text = s.salary.toString();
    }
  }

  Future<void> _save() async {
    final salary = double.tryParse(_salaryCtrl.text) ?? 0;

    if (widget.staff == null) {
      final emp = Staff(
        salary,
        id: uuid.v4(),
        name: _nameCtrl.text,
        position: _positionCtrl.text,
      );

      await firestore.addEmployee(emp);
    } else {
      final updated = Staff(
        salary,
        id: widget.staff!.id,
        name: _nameCtrl.text,
        position: _positionCtrl.text,
      );

      await firestore.updateEmployee(updated);
    }

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.staff != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa nhân viên' : 'Thêm nhân viên')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Tên nhân viên'),
            ),
            TextField(
              controller: _positionCtrl,
              decoration: const InputDecoration(labelText: 'Chức vụ'),
            ),
            TextField(
              controller: _salaryCtrl,
              decoration: const InputDecoration(labelText: 'Lương'),
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

  Future<void> _saveAndContinue() async {
    final salary = double.tryParse(_salaryCtrl.text) ?? 0;

    if (widget.staff == null) {
      final emp = Staff(
        salary,
        id: uuid.v4(),
        name: _nameCtrl.text,
        position: _positionCtrl.text,
      );

      await firestore.addEmployee(emp);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu')));

      _nameCtrl.clear();
      _positionCtrl.clear();
      _salaryCtrl.clear();
    } else {
      final updated = Staff(
        salary,
        id: widget.staff!.id,
        name: _nameCtrl.text,
        position: _positionCtrl.text,
      );

      await firestore.updateEmployee(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật')));
    }
  }
}
