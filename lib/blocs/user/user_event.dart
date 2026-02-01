// lib/blocs/user/user_event.dart
import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load Firestore user for the given uid (called when AuthBloc becomes authenticated).
class UserLoadRequested extends UserEvent {
  final String uid;

  UserLoadRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

/// Clear user (e.g. when AuthBloc becomes unauthenticated).
class UserClearRequested extends UserEvent {}

/// Refresh user document from Firestore (e.g. after admin approves driver).
class UserRefreshRequested extends UserEvent {
  final String uid;

  UserRefreshRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}
