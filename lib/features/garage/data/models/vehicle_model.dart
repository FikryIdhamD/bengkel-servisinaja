class Vehicle {
  final String id;
  final String userId;
  final String plateNumber;
  final String modelName;
  final int year;
  final DateTime createdAt;

  Vehicle({
    required this.id,
    required this.userId,
    required this.plateNumber,
    required this.modelName,
    required this.year,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      userId: json['user_id'],
      plateNumber: json['plate_number'],
      modelName: json['model_name'],
      year: json['year'] is int
          ? json['year']
          : int.parse(json['year'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plate_number': plateNumber,
      'model_name': modelName,
      'year': year,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
