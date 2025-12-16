// This file defines the Staff model.
// A model represents the data structure for a staff member in the app.

// The Staff class holds information about a staff member.
class Staff {
  // Unique identifier for the staff member.
  final String id;
  // Name of the staff member.
  final String name;
  // Job position of the staff member.
  final String position;
  // Salary of the staff member (can be changed).
  double salary;

  // Constructor to create a new Staff object.
  // Salary is passed as a positional parameter, others as named.
  Staff(
    this.salary, {
    required this.id,
    required this.name,
    required this.position,
  });

  // Convert the Staff object to a map for saving to Firestore.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position,
    'salary': salary,
  };

  // Create a Staff object from data loaded from Firestore.
  factory Staff.fromJson(Map<String, dynamic> json, {String? id}) {
    return Staff(
      // Convert salary to double.
      (json['salary'] as num).toDouble(),
      // Use provided id, or get from json, or empty string.
      id: id ?? json['id'] ?? '',
      name: json['name'] ?? '',
      position: json['position'] ?? '',
    );
  }
}
