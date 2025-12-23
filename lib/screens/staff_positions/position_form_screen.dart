// File: lib/screens/position/position_form_screen.dart
// Màn hình thêm/sửa vị trí công việc

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/position.dart';
import '../../services/position_firestore.dart';
import 'package:uuid/uuid.dart';

class PositionFormScreen extends StatefulWidget {
  final Position? position; // Nếu có position → Sửa, nếu null → Thêm mới

  const PositionFormScreen({super.key, this.position});

  @override
  State<PositionFormScreen> createState() => _PositionFormScreenState();
}

class _PositionFormScreenState extends State<PositionFormScreen> {
  // Controllers để quản lý text trong form
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();

  // Services
  final _firestore = PositionFirestore();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Nếu đang sửa → Điền dữ liệu cũ vào form
    if (widget.position != null) {
      _nameController.text = widget.position!.name;
      _descriptionController.text = widget.position!.description ?? '';
      _salaryController.text = widget.position!.baseSalary?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ
    _nameController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  // Hàm lưu position
  Future<void> _save() async {
    // Validate: Tên không được rỗng
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên vị trí')));
      return;
    }

    // Tạo ID
    String id = widget.position?.id ?? _uuid.v4();

    // Parse lương
    double? salary;
    if (_salaryController.text.trim().isNotEmpty) {
      salary = double.tryParse(_salaryController.text);
      if (salary == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lương không hợp lệ')));
        return;
      }
    }

    // Tạo object Position
    final position = Position(
      id: id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      baseSalary: salary,
    );

    // Lưu vào Firestore
    try {
      if (widget.position == null) {
        // Thêm mới
        await _firestore.addPosition(position);
      } else {
        // Cập nhật
        await _firestore.updatePosition(position);
      }

      if (!mounted) return;

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.position == null ? 'Đã thêm vị trí' : 'Đã cập nhật vị trí',
          ),
        ),
      );

      // Quay lại màn hình trước
      context.pop();
    } catch (e) {
      if (!mounted) return;

      // Hiển thị lỗi
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.position != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa vị trí' : 'Thêm vị trí')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Trường nhập TÊN VỊ TRÍ
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên vị trí *',
                hintText: 'VD: Kỹ sư cơ khí',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
            ),
            const SizedBox(height: 16),

            // Trường nhập MÔ TẢ
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                hintText: 'VD: Sửa chữa động cơ, hộp số',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Trường nhập LƯƠNG CƠ BẢN
            TextField(
              controller: _salaryController,
              decoration: const InputDecoration(
                labelText: 'Lương cơ bản',
                hintText: 'VD: 15000000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'VNĐ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // NÚT LƯU
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Lưu'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
