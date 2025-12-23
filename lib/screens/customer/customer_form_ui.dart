import 'package:flutter/material.dart';
import 'package:flutter_application/screens/customer/customer_form_controller.dart';

class CustomerFormUI extends StatelessWidget {
  final CustomerFormController controller;

  const CustomerFormUI({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: controller.nameCtrl,
            decoration: const InputDecoration(labelText: 'Tên'),
          ),
          TextField(
            controller: controller.phoneCtrl,
            decoration: const InputDecoration(labelText: 'Số điện thoại'),
          ),
          TextField(
            controller: controller.emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: controller.addressCtrl,
            decoration: const InputDecoration(labelText: 'Địa chỉ'),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Thêm xe cho khách hàng'),
            value: controller.addVehicle,
            onChanged: controller.toggleAddVehicle,
          ),
          if (controller.addVehicle) ...[
            TextField(
              controller: controller.brandCtrl,
              decoration: const InputDecoration(labelText: 'Hãng xe'),
            ),
            TextField(
              controller: controller.modelCtrl,
              decoration: const InputDecoration(labelText: 'Model xe'),
            ),
            TextField(
              controller: controller.yearCtrl,
              decoration: const InputDecoration(labelText: 'Năm sản xuất'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: controller.plateNumberCtrl,
              decoration: const InputDecoration(labelText: 'Biển số xe'),
            ),
            TextField(
              controller: controller.colorCtrl,
              decoration: const InputDecoration(labelText: 'Màu xe'),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleSave(context),
                  child: const Text('Lưu'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleSaveAndContinue(context),
                  child: const Text('Lưu & Thêm tiếp'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    await controller.save();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSaveAndContinue(BuildContext context) async {
    await controller.saveAndContinue();
    if (context.mounted) {
      final message = controller.isEdit ? 'Đã cập nhật' : 'Đã lưu';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
