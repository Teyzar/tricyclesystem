// lib/blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String role;
  final String plateNumber;

  RegisterEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.role,
    required this.plateNumber,
  });

  @override
  List<Object?> get props => [email, password, name, phone, role, plateNumber];
}

class LogoutEvent extends AuthEvent {}
