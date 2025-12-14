class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final int? durationInMinutes;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.durationInMinutes,
  });

  /// Chỉ map dữ liệu Firestore
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    'durationInMinutes': durationInMinutes,
  };

  factory Service.fromJson(Map<String, dynamic> json, {required String id}) {
    final priceValue = json['price'];

    return Service(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: priceValue is int
          ? priceValue.toDouble()
          : (priceValue is double ? priceValue : 0.0),
      durationInMinutes: json['durationInMinutes'] as int?,
    );
  }
}
