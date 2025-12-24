// File: lib/screens/reception/reception_form_screen.dart
// Dropdown nhân viên CHỈ HIỂN THỊ những người phù hợp với dịch vụ

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

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
import 'package:flutter_application/services/task_assignment_firestore.dart';

class ReceptionFormScreen extends StatefulWidget {
  final Reception? reception;

  const ReceptionFormScreen({super.key, this.reception});

  @override
  State<ReceptionFormScreen> createState() => _ReceptionFormScreenState();
}

class _ReceptionFormScreenState extends State<ReceptionFormScreen> {
  // Controllers
  final TextEditingController _totalPriceController = TextEditingController();

  // Selected values
  String? _selectedCustomerId;
  String? _selectedVehicleId;
  List<String> _selectedStaffIds = [];
  List<String> _selectedServiceIds = [];
  String _selectedStatus = 'pending';

  // Data lists
  List<Staff> _filteredStaff = [];
  List<Staff> _allStaff = [];
  List<Service> _allServices = [];

  // Firestore Services
  final ReceptionFirestore _receptionService = ReceptionFirestore();
  final CustomerFirestore _customerService = CustomerFirestore();
  final VehicleFirestore _vehicleService = VehicleFirestore();
  final StaffFirestore _staffService = StaffFirestore();
  final ServiceFirestore _serviceService = ServiceFirestore();
  final TaskAssignmentFirestore _taskAssignmentService =
      TaskAssignmentFirestore();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.reception != null) {
      _selectedCustomerId = widget.reception!.customerId;
      _selectedVehicleId = widget.reception!.vehicleId;
      _selectedStaffIds = List.from(widget.reception!.staffIds);
      _selectedServiceIds = List.from(widget.reception!.serviceIds);
      _totalPriceController.text = widget.reception!.totalPrice.toString();
      _selectedStatus = widget.reception!.status;
    }
  }

  @override
  void dispose() {
    _totalPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final staff = await _staffService.getAllStaff();
    final services = await _serviceService.getAllServices();

    setState(() {
      _allStaff = staff;
      _allServices = services;
    });

    // Nếu đang edit và đã có service IDs → Update filtered staff
    if (widget.reception != null && _selectedServiceIds.isNotEmpty) {
      _updateFilteredStaff();
    }
  }

  void _calculateTotalPrice(List<Service> services) {
    double total = 0.0;
    for (var id in _selectedServiceIds) {
      final service = services.firstWhere(
        (s) => s.id == id,
        orElse: () => Service(
          id: '',
          name: '',
          description: '',
          price: 0.0,
          positionId: '',
          positionName: '',
        ),
      );
      total += service.price;
    }
    _totalPriceController.text = total.toString();
  }

  void _updateFilteredStaff() {
    if (_selectedServiceIds.isEmpty) {
      setState(() {
        _filteredStaff = [];
        _selectedStaffIds = [];
      });
      return;
    }

    final requiredPositionIds = <String>{};

    for (final serviceId in _selectedServiceIds) {
      final service = _allServices.firstWhere(
        (s) => s.id == serviceId,
        orElse: () => Service(
          id: '',
          name: '',
          price: 0.0,
          positionId: '',
          positionName: '',
        ),
      );

      if (service.positionId.isNotEmpty) {
        requiredPositionIds.add(service.positionId);
      }
    }

    final filtered = _allStaff.where((staff) {
      return requiredPositionIds.contains(staff.positionId);
    }).toList();

    setState(() {
      _filteredStaff = filtered;
      _selectedStaffIds.removeWhere((staffId) {
        return !filtered.any((s) => s.id == staffId);
      });
    });
  }

  Future<void> _save() async {
    if (_selectedCustomerId == null ||
        _selectedVehicleId == null ||
        _selectedStaffIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đầy đủ thông tin')),
      );
      return;
    }

    if (_selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 dịch vụ')),
      );
      return;
    }

    double totalPrice = double.tryParse(_totalPriceController.text) ?? 0.0;

    String id = widget.reception?.id ?? _uuid.v4();
    Reception reception = Reception(
      id: id,
      customerId: _selectedCustomerId!,
      vehicleId: _selectedVehicleId!,
      staffIds: _selectedStaffIds,
      serviceIds: _selectedServiceIds,
      totalPrice: totalPrice,
      status: _selectedStatus,
      createdAt: widget.reception?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.reception == null) {
        await _receptionService.addReception(reception);
        await _autoCreateTasks(reception);
      } else {
        await _receptionService.updateReception(reception);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.reception == null
                ? 'Đã tạo phiếu tiếp nhận'
                : 'Đã cập nhật phiếu',
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

  Future<void> _autoCreateTasks(Reception reception) async {
    final serviceNames = <String>[];
    for (final serviceId in reception.serviceIds) {
      final service = _allServices.firstWhere(
        (s) => s.id == serviceId,
        orElse: () => Service(
          id: '',
          name: 'Unknown',
          price: 0,
          positionId: '',
          positionName: '',
        ),
      );
      serviceNames.add(service.name);
    }

    final staffNames = <String>[];
    for (final staffId in reception.staffIds) {
      final staff = _allStaff.firstWhere(
        (s) => s.id == staffId,
        orElse: () => Staff(
          id: '',
          name: 'Unknown',
          positionId: '',
          positionName: '',
          salary: 0,
        ),
      );
      staffNames.add(staff.name);
    }

    await _taskAssignmentService.autoCreateTasksFromReception(
      receptionId: reception.id,
      serviceIds: reception.serviceIds,
      serviceNames: serviceNames,
      staffIds: reception.staffIds,
      staffNames: staffNames,
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerSection(),
              const SizedBox(height: 16),
              _buildVehicleSection(),
              const SizedBox(height: 16),
              _buildServiceSection(),
              const SizedBox(height: 16),
              _buildStaffSection(),
              const SizedBox(height: 16),
              _buildTotalPriceSection(),
              const SizedBox(height: 16),
              _buildStatusSection(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👤 Khách hàng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Customer>>(
          stream: _customerService.streamCustomers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return DropdownButtonFormField<String>(
              key: ValueKey(_selectedCustomerId),
              initialValue: _selectedCustomerId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Chọn khách hàng',
              ),
              items: snapshot.data!.map((c) {
                return DropdownMenuItem(value: c.id, child: Text(c.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomerId = value;
                  _selectedVehicleId = null;
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🚗 Phương tiện',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
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
              key: ValueKey(_selectedVehicleId),
              initialValue: _selectedVehicleId,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: _selectedCustomerId == null
                    ? 'Vui lòng chọn khách hàng trước'
                    : 'Chọn phương tiện',
              ),
              items: filteredVehicles.map((v) {
                return DropdownMenuItem(
                  value: v.id,
                  child: Text('${v.brand} ${v.model} (${v.plateNumber})'),
                );
              }).toList(),
              onChanged: _selectedCustomerId == null
                  ? null
                  : (value) => setState(() => _selectedVehicleId = value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔧 Dịch vụ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Service>>(
          stream: _serviceService.getServices(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final services = snapshot.data!;

            return Card(
              child: Column(
                children: services.map((service) {
                  return CheckboxListTile(
                    title: Text(service.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💰 ${_formatMoney(service.price)}'),
                        Text(
                          '👨‍🔧 Cần: ${service.positionName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    value: _selectedServiceIds.contains(service.id),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedServiceIds.add(service.id);
                        } else {
                          _selectedServiceIds.remove(service.id);
                        }
                        _calculateTotalPrice(services);
                        _updateFilteredStaff();
                      });
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStaffSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👨‍🔧 Nhân viên phụ trách',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_selectedServiceIds.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vui lòng chọn dịch vụ trước',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          )
        else if (_filteredStaff.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '⚠️ Không có nhân viên phù hợp',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
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
                        'Có ${_filteredStaff.length} nhân viên phù hợp',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: _filteredStaff.map((staff) {
                    final isSelected = _selectedStaffIds.contains(staff.id);
                    return CheckboxListTile(
                      title: Text(
                        staff.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${staff.positionName} • ${_formatMoney(staff.salary)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      value: isSelected,
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedStaffIds.add(staff.id);
                          } else {
                            _selectedStaffIds.remove(staff.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTotalPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💰 Tổng tiền',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _totalPriceController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixText: 'VNĐ',
          ),
          keyboardType: TextInputType.number,
          readOnly: true,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 Trạng thái',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey(_selectedStatus),
          initialValue: _selectedStatus,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'pending', child: Text('⏳ Đang chờ')),
            DropdownMenuItem(value: 'in_progress', child: Text('🔧 Đang sửa')),
            DropdownMenuItem(value: 'done', child: Text('✅ Hoàn thành')),
            DropdownMenuItem(value: 'canceled', child: Text('❌ Đã hủy')),
          ],
          onChanged: (value) => setState(() => _selectedStatus = value!),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _save,
        icon: const Icon(Icons.save),
        label: const Text('Lưu phiếu'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  String _formatMoney(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')} VNĐ';
  }
}
