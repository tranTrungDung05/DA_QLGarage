// File: lib/models/service.dart
// Model Service CÓ positionId và positionName

class Service {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String positionId;
  final String positionName;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.positionId,
    required this.positionName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'positionId': positionId,
      'positionName': positionName,
    };
  }

  factory Service.fromJson(Map<String, dynamic> json, {String? id}) {
    return Service(
      id: id ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      positionId: json['positionId'] ?? '',
      positionName: json['positionName'] ?? '',
    );
  }
}
