import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/reception.dart';
import 'package:flutter_application/models/customer.dart';
import 'package:flutter_application/models/vehicle.dart';
import 'package:flutter_application/models/staff.dart';
import 'package:flutter_application/models/service.dart';
import 'package:flutter_application/services/reception_firestore.dart';
import 'package:flutter_application/services/customer_firestore.dart';
import 'package:flutter_application/services/vehicle_firestore.dart';
import 'package:flutter_application/services/staff_firestore.dart';
import 'package:flutter_application/services/service_firestore.dart';
import 'package:uuid/uuid.dart';

// Màn hình form để thêm hoặc sửa phiếu tiếp nhận
class ReceptionFormScreen extends StatefulWidget {
  final Reception? reception; // Nếu có thì là chế độ sửa

  const ReceptionFormScreen({super.key, this.reception});

  @override
  State<ReceptionFormScreen> createState() => _ReceptionFormScreenState();
}

class _ReceptionFormScreenState extends State<ReceptionFormScreen> {
  // Controllers cho form
  final TextEditingController _totalPriceController = TextEditingController();
  String? _selectedCustomerId;
  String? _selectedVehicleId;
  String? _selectedStaffId;
  List<String> _selectedServiceIds = [];
  String _selectedStatus = 'pending';

  // Services
  final ReceptionFirestore _receptionService = ReceptionFirestore();
  final CustomerFirestore _customerService = CustomerFirestore();
  final VehicleFirestore _vehicleService = VehicleFirestore();
  final StaffFirestore _staffService = StaffFirestore();
  final ServiceFirestore _serviceService = ServiceFirestore();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Nếu đang sửa, điền sẵn dữ liệu
    if (widget.reception != null) {
      _selectedCustomerId = widget.reception!.customerId;
      _selectedVehicleId = widget.reception!.vehicleId;
      _selectedStaffId = widget.reception!.staffId;
      _selectedServiceIds = List.from(widget.reception!.serviceIds);
      _totalPriceController.text = widget.reception!.totalPrice.toString();
      _selectedStatus = widget.reception!.status;
      // Tính tổng nếu cần, nhưng vì đã có totalPrice, có lẽ không cần
    }
  }

  void _calculateTotalPrice(List<Service> services) {
    double total = 0.0;
    for (var id in _selectedServiceIds) {
      final service = services.firstWhere(
        (s) => s.id == id,
        orElse: () => Service(id: '', name: '', description: '', price: 0.0),
      );
      total += service.price;
    }
    _totalPriceController.text = total.toString();
  }

  // Hàm lưu
  Future<void> _save() async {
    double totalPrice = double.tryParse(_totalPriceController.text) ?? 0.0;

    if (_selectedCustomerId == null ||
        _selectedVehicleId == null ||
        _selectedStaffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đầy đủ thông tin')),
      );
      return;
    }

    String id = widget.reception?.id ?? _uuid.v4();
    Reception reception = Reception(
      id: id,
      customerId: _selectedCustomerId!,
      vehicleId: _selectedVehicleId!,
      staffId: _selectedStaffId!,
      serviceIds: _selectedServiceIds,
      totalPrice: totalPrice,
      status: _selectedStatus,
      createdAt: widget.reception?.createdAt ?? DateTime.now(),
    );

    if (widget.reception == null) {
      await _receptionService.addReception(reception);
    } else {
      // Cập nhật toàn bộ
      await _receptionService.updateReception(reception);
    }

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.reception != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa phiếu tiếp nhận' : 'Thêm phiếu tiếp nhận'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Dropdown chọn khách hàng
              StreamBuilder<List<Customer>>(
                stream: _customerService.streamCustomers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCustomerId,
                    items: snapshot.data!
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCustomerId = value;
                        _selectedVehicleId =
                            null; // Reset vehicle khi đổi customer
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Chọn khách hàng',
                    ),
                  );
                },
              ),
              // Dropdown chọn phương tiện
              StreamBuilder<List<Vehicle>>(
                stream: _vehicleService.getVehicles(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final filteredVehicles = _selectedCustomerId == null
                      ? <Vehicle>[]
                      : snapshot.data!
                            .where((v) => v.customerId == _selectedCustomerId)
                            .toList();
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedVehicleId,
                    items: filteredVehicles
                        .map(
                          (v) => DropdownMenuItem(
                            value: v.id,
                            child: Text(
                              '${v.brand} ${v.model} (${v.plateNumber})',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _selectedCustomerId == null
                        ? null
                        : (value) => setState(() => _selectedVehicleId = value),
                    decoration: InputDecoration(
                      labelText: 'Chọn phương tiện',
                      hintText: _selectedCustomerId == null
                          ? 'Vui lòng chọn khách hàng trước'
                          : null,
                    ),
                  );
                },
              ),
              // Dropdown chọn nhân viên
              StreamBuilder<List<Staff>>(
                stream: _staffService.getEmployees(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedStaffId,
                    items: snapshot.data!
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedStaffId = value),
                    decoration: const InputDecoration(
                      labelText: 'Chọn nhân viên',
                    ),
                  );
                },
              ),
              // Multi-select cho dịch vụ (đơn giản hóa bằng checkbox list)
              const Text('Chọn dịch vụ:'),
              StreamBuilder<List<Service>>(
                stream: _serviceService.getServices(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final services = snapshot.data!;
                  return Column(
                    children: [
                      // ignore: unnecessary_to_list_in_spreads
                      ...services.map((service) {
                        return CheckboxListTile(
                          title: Text('${service.name} - ${service.price} VND'),
                          value: _selectedServiceIds.contains(service.id),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedServiceIds.add(service.id);
                              } else {
                                _selectedServiceIds.remove(service.id);
                              }
                              _calculateTotalPrice(services);
                            });
                          },
                        );
                      }),
                    ],
                  );
                },
              ),
              // TextField cho tổng tiền (tự động tính)
              TextField(
                controller: _totalPriceController,
                decoration: const InputDecoration(
                  labelText: 'Tổng tiền (tự động)',
                ),
                keyboardType: TextInputType.number,
                readOnly: true,
              ),
              // Dropdown cho trạng thái
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                items: ['pending', 'in_progress', 'done', 'canceled']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
                decoration: const InputDecoration(labelText: 'Trạng thái'),
              ),
              const SizedBox(height: 24),
              // Nút lưu
              ElevatedButton(onPressed: _save, child: const Text('Lưu')),
            ],
          ),
        ),
      ),
    );
  }
}
