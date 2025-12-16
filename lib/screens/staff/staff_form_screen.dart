import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/staff.dart';
import 'package:flutter_application/services/staff_firestore.dart';
import 'package:uuid/uuid.dart';

// Màn hình để thêm hoặc sửa thông tin nhân viên
class StaffFormScreen extends StatefulWidget {
  final Staff?
  staff; // Nếu có staff thì là chế độ sửa, nếu null thì là thêm mới

  const StaffFormScreen({super.key, this.staff});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  // Các controller để quản lý text trong form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  // Dịch vụ để lưu dữ liệu lên Firestore
  final StaffFirestore _firestoreService = StaffFirestore();
  // Để tạo ID duy nhất cho nhân viên mới
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Nếu đang sửa, điền sẵn thông tin cũ vào form
    if (widget.staff != null) {
      _nameController.text = widget.staff!.name;
      _positionController.text = widget.staff!.position;
      _salaryController.text = widget.staff!.salary.toString();
    }
  }

  // Hàm tạo đối tượng Staff từ dữ liệu form
  Staff _createStaffFromForm(String id) {
    double salary = double.tryParse(_salaryController.text) ?? 0.0;
    return Staff(
      salary,
      id: id,
      name: _nameController.text,
      position: _positionController.text,
    );
  }

  // Hàm lưu và quay lại
  Future<void> _save() async {
    String id =
        widget.staff?.id ??
        _uuid.v4(); // Nếu sửa thì dùng ID cũ, nếu thêm thì tạo mới
    Staff staff = _createStaffFromForm(id);

    if (widget.staff == null) {
      // Thêm nhân viên mới
      await _firestoreService.addEmployee(staff);
    } else {
      // Cập nhật nhân viên cũ
      await _firestoreService.updateEmployee(staff);
    }

    if (!mounted) return;
    context.pop(); // Quay lại màn hình trước
  }

  // Hàm lưu và tiếp tục thêm
  Future<void> _saveAndContinue() async {
    if (widget.staff != null) {
      // Nếu đang sửa, không có chức năng "lưu và tiếp tục"
      await _save();
      return;
    }

    // Tạo nhân viên mới
    String id = _uuid.v4();
    Staff staff = _createStaffFromForm(id);
    await _firestoreService.addEmployee(staff);

    if (!mounted) return;
    // Hiển thị thông báo
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu nhân viên')));

    // Xóa sạch form để thêm tiếp
    _nameController.clear();
    _positionController.clear();
    _salaryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.staff != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa nhân viên' : 'Thêm nhân viên'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Trường nhập tên
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên nhân viên'),
            ),
            // Trường nhập chức vụ
            TextField(
              controller: _positionController,
              decoration: const InputDecoration(labelText: 'Chức vụ'),
            ),
            // Trường nhập lương
            TextField(
              controller: _salaryController,
              decoration: const InputDecoration(labelText: 'Lương'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Nút lưu
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Lưu'),
                  ),
                ),
                const SizedBox(width: 12),
                // Nút lưu và thêm tiếp (chỉ hiện khi thêm mới)
                if (!isEditing)
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
