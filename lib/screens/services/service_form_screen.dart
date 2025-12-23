import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/service.dart';
import 'package:flutter_application/models/position.dart';
import '../../services/service_firestore.dart';
import '../../services/position_firestore.dart';
import 'package:uuid/uuid.dart';

class ServiceFormScreen extends StatefulWidget {
  final Service? service;

  const ServiceFormScreen({super.key, this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  // Selected position
  Position? _selectedPosition;

  // Loading
  bool _isLoadingPositions = true;
  List<Position> _positions = [];

  // Services
  final _serviceFirestore = ServiceFirestore();
  final _positionFirestore = PositionFirestore();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadPositions();

    // Nếu đang sửa
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description ?? '';
      _priceController.text = widget.service!.price.toString();

      // Load position của service hiện tại
      // Sẽ set _selectedPosition sau khi load positions xong
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadPositions() async {
    try {
      final positions = await _positionFirestore.getAllPositions();
      setState(() {
        _positions = positions;
        _isLoadingPositions = false;

        // Nếu đang edit service, tìm position hiện tại
        if (widget.service != null) {
          _selectedPosition = positions.firstWhere(
            (p) => p.id == widget.service!.positionId,
            orElse: () => positions.first,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingPositions = false;
      });
    }
  }

  Future<void> _save() async {
    // Validate
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên dịch vụ')),
      );
      return;
    }

    if (_selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn vị trí phụ trách')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập giá hợp lệ')));
      return;
    }

    // Tạo Service object
    String id = widget.service?.id ?? _uuid.v4();

    // ===== QUAN TRỌNG: Tạo Service CÓ positionId =====
    final service = Service(
      id: id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      price: price,
      positionId: _selectedPosition!.id, // ← Thêm positionId
      positionName: _selectedPosition!.name, // ← Thêm positionName
    );

    // Lưu
    try {
      if (widget.service == null) {
        await _serviceFirestore.addService(service);
      } else {
        await _serviceFirestore.updateService(service);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.service == null ? 'Đã thêm dịch vụ' : 'Đã cập nhật dịch vụ',
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.service != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa dịch vụ' : 'Thêm dịch vụ')),
      body: _isLoadingPositions
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TÊN DỊCH VỤ
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên dịch vụ *',
                        hintText: 'VD: Kiểm tra động cơ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.build),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // MÔ TẢ
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        hintText: 'VD: Kiểm tra tổng thể động cơ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // GIÁ
                    TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Giá *',
                        hintText: 'VD: 500000',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: 'VNĐ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // ===== CHỌN VỊ TRÍ PHỤ TRÁCH =====
                    const Text(
                      '👨‍🔧 Vị trí phụ trách *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chọn vị trí nhân viên phù hợp để làm dịch vụ này',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    if (_positions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            SizedBox(height: 8),
                            Text(
                              'Chưa có vị trí nào. Vui lòng tạo vị trí trước!',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<Position>(
                        initialValue: _selectedPosition,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Chọn vị trí',
                          prefixIcon: Icon(Icons.work),
                        ),
                        items: _positions.map((position) {
                          return DropdownMenuItem(
                            value: position,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(position.name),
                                if (position.description != null)
                                  Text(
                                    position.description!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (position) {
                          setState(() {
                            _selectedPosition = position;
                          });
                        },
                      ),

                    // Hiển thị info về position đã chọn
                    if (_selectedPosition != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Nhân viên có vị trí "${_selectedPosition!.name}" '
                                  'sẽ được gợi ý khi chọn dịch vụ này',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

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
            ),
    );
  }
}
