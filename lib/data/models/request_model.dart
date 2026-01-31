class RequestModel {
  final String? id;
  final String driverName;
  final String driverEmail;
  final String? plateNumber;
  final String status; // 'pending', 'approved', 'rejected', 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;

  RequestModel({
    this.id,
    required this.driverName,
    required this.driverEmail,
    this.plateNumber,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'] ?? '',
      driverName: json['name'] ?? '',
      driverEmail: json['email'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] is DateTime
                ? json['createdAt']
                : (json['createdAt'] != null && json['createdAt'].toDate != null
                      ? json['createdAt'].toDate()
                      : DateTime.now())),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is String
                ? DateTime.parse(json['updatedAt'])
                : (json['updatedAt'] is DateTime
                      ? json['updatedAt']
                      : (json['updatedAt'] != null &&
                                json['updatedAt'].toDate != null
                            ? json['updatedAt'].toDate()
                            : null)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverName': driverName,
      'driverEmail': driverEmail,
      'plateNumber': plateNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  RequestModel copyWith({
    String? id,
    String? driverName,
    String? driverEmail,
    String? plateNumber,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? pickupLocation,
    String? destination,
    String? notes,
  }) {
    return RequestModel(
      id: id ?? this.id,
      driverName: driverName ?? this.driverName,
      driverEmail: driverEmail ?? this.driverEmail,
      plateNumber: plateNumber ?? this.plateNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
