// lib/blocs/auth/auth_state.dart
import 'package:equatable/equatable.dart';

/// Auth state reflects Firebase Auth only (single source of truth).
/// Firestore user data (role, status) is in UserBloc.
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state before auth stream has emitted (e.g. app just started).
class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// User is signed in to Firebase. [uid] is the Firebase Auth UID.
/// Do NOT hold UserModel here — that lives in UserBloc.
class AuthAuthenticated extends AuthState {
  final String uid;

  AuthAuthenticated({required this.uid});

  @override
  List<Object?> get props => [uid];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String errorMessage;

  AuthError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
