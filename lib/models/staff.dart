class Staff {
  final String id;
  final String name;
  final String position;
  double salary;

  Staff(
    this.salary, {
    required this.id,
    required this.name,
    required this.position,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position,
    'salary': salary,
  };

  factory Staff.fromJson(Map<String, dynamic> json, {String? id}) {
    return Staff(
      (json['salary'] as num).toDouble(),
      id: id ?? json['id'] ?? '',
      name: json['name'] ?? '',
      position: json['position'] ?? '',
    );
  }
}
