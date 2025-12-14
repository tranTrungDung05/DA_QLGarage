class Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String plateNumber;
  final String? color;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plateNumber,
    this.color,
  });

  Map<String, dynamic> toJson() => {
    'brand': brand,
    'model': model,
    'year': year,
    'plateNumber': plateNumber,
    'color': color,
  };

  factory Vehicle.fromJson(Map<String, dynamic> json, {required String id}) {
    return Vehicle(
      id: id,
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      plateNumber: json['plateNumber'] ?? '',
      color: json['color'] as String?,
    );
  }
}
