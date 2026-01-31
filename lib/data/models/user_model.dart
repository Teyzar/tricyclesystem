// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String email;
  final String? name;
  final String? password;
  final String? phone;
  final String? role;
  String? plateNumber;
  String? status;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  UserModel({
    this.id,
    required this.email,
    this.name,
    this.password,
    this.phone,
    this.role,
    this.plateNumber,
    this.status,
    this.createdAt,
    this.updatedAt,
  });
}
