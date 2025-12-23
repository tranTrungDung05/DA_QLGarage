// File: lib/screens/staff/staff_form_screen.dart
// Màn hình thêm/sửa nhân viên (đơn giản)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/staff.dart';
import '../../models/position.dart';
import '../../services/staff_firestore.dart';
import '../../services/position_firestore.dart';
import 'package:uuid/uuid.dart';

class StaffFormScreen extends StatefulWidget {
  final Staff? staff;

  const StaffFormScreen({super.key, this.staff});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _salaryController = TextEditingController();

  // Services
  final _staffFirestore = StaffFirestore();
  final _positionFirestore = PositionFirestore();
  final _uuid = const Uuid();

  // State
  Position? _selectedPosition;
  List<Position> _positions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPositions();

    // Nếu đang sửa → Điền dữ liệu cũ
    if (widget.staff != null) {
      _nameController.text = widget.staff!.name;
      _salaryController.text = widget.staff!.salary.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  // Load danh sách positions
  Future<void> _loadPositions() async {
    try {
      final positions = await _positionFirestore.getAllPositions();
      setState(() {
        _positions = positions;
        _isLoading = false;

        // Nếu đang sửa → Tìm position hiện tại
        if (widget.staff != null) {
          _selectedPosition = positions.firstWhere(
            (p) => p.id == widget.staff!.positionId,
            orElse: () => positions.first,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi load positions: $e')));
      }
    }
  }

  // Lưu staff
  Future<void> _save() async {
    // Validate
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên nhân viên')),
      );
      return;
    }

    if (_selectedPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn vị trí')));
      return;
    }

    final salary = double.tryParse(_salaryController.text);
    if (salary == null || salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lương hợp lệ')),
      );
      return;
    }

    // Tạo Staff object
    final id = widget.staff?.id ?? _uuid.v4();
    final staff = Staff(
      id: id,
      name: _nameController.text.trim(),
      positionId: _selectedPosition!.id,
      positionName: _selectedPosition!.name,
      salary: salary,
    );

    // Lưu vào Firestore
    try {
      if (widget.staff == null) {
        await _staffFirestore.addEmployee(staff);
      } else {
        await _staffFirestore.updateEmployee(staff);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.staff == null
                ? 'Đã thêm nhân viên'
                : 'Đã cập nhật nhân viên',
          ),
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  // Lưu và thêm tiếp
  Future<void> _saveAndContinue() async {
    if (widget.staff != null) {
      // Nếu đang sửa → Chỉ lưu
      await _save();
      return;
    }

    // Validate
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên nhân viên')),
      );
      return;
    }

    if (_selectedPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn vị trí')));
      return;
    }

    final salary = double.tryParse(_salaryController.text);
    if (salary == null || salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lương hợp lệ')),
      );
      return;
    }

    // Tạo Staff object
    final id = _uuid.v4();
    final staff = Staff(
      id: id,
      name: _nameController.text.trim(),
      positionId: _selectedPosition!.id,
      positionName: _selectedPosition!.name,
      salary: salary,
    );

    // Lưu
    try {
      await _staffFirestore.addEmployee(staff);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu nhân viên')));

      // Clear form
      _nameController.clear();
      _salaryController.clear();
      setState(() {
        _selectedPosition = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.staff != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa nhân viên' : 'Thêm nhân viên')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // TÊN NHÂN VIÊN
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên nhân viên *',
                      hintText: 'Nguyễn Văn A',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CHỌN VỊ TRÍ
                  DropdownButtonFormField<Position>(
                    initialValue: _selectedPosition,
                    decoration: const InputDecoration(
                      labelText: 'Vị trí *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                    hint: const Text('Chọn vị trí'),
                    items: _positions.map((position) {
                      return DropdownMenuItem(
                        value: position,
                        child: Text(position.name),
                      );
                    }).toList(),
                    onChanged: (position) {
                      setState(() {
                        _selectedPosition = position;
                        // Auto-fill lương theo position
                        if (position?.baseSalary != null) {
                          _salaryController.text = position!.baseSalary!
                              .toStringAsFixed(0);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // LƯƠNG
                  TextField(
                    controller: _salaryController,
                    decoration: const InputDecoration(
                      labelText: 'Lương *',
                      hintText: '15000000',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      suffixText: 'VNĐ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // NÚT LƯU
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          child: const Text('Lưu'),
                        ),
                      ),
                      if (!isEdit) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveAndContinue,
                            child: const Text('Lưu & Thêm tiếp'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
