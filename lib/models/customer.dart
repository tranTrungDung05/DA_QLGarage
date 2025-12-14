class Customer {
  final String id;
  final String phoneNumber;
  final String name;
  final String? email;
  final String? address;

  Customer({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.email,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'name': name,
    'email': email,
    'address': address,
  };

  factory Customer.fromJson(Map<String, dynamic> json, {required String id}) {
    return Customer(
      id: id,
      phoneNumber: json['phoneNumber'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
    );
  }
}
