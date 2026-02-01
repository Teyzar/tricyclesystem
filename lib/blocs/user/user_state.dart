// lib/blocs/user/user_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

/// User state holds Firestore user data (role, status). Used for routing and UI.
abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;

  UserLoaded({required this.user});

  @override
  List<Object?> get props => [user.id, user.role, user.status];
}

class UserError extends UserState {
  final String message;

  UserError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Auth signed out — no user document.
class UserUnauthenticated extends UserState {}
