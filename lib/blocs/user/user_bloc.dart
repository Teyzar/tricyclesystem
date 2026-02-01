// lib/blocs/user/user_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

/// Holds Firestore user data (role, status). No Firebase Auth here — that's AuthBloc.
/// Listen to AuthBloc from outside and dispatch UserLoadRequested(uid) / UserClearRequested.
class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthRepository authRepository;

  UserBloc({required this.authRepository}) : super(UserInitial()) {
    on<UserLoadRequested>(_onLoadRequested);
    on<UserClearRequested>(_onClearRequested);
    on<UserRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    UserLoadRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await authRepository.getUserDocument(event.uid);
      if (user != null) {
        emit(UserLoaded(user: user));
      } else {
        emit(UserError(message: 'User document not found'));
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  void _onClearRequested(UserClearRequested event, Emitter<UserState> emit) {
    emit(UserUnauthenticated());
  }

  Future<void> _onRefreshRequested(
    UserRefreshRequested event,
    Emitter<UserState> emit,
  ) async {
    final current = state;
    if (current is UserLoaded) emit(UserLoading());
    try {
      final user = await authRepository.getUserDocument(event.uid);
      if (user != null) {
        emit(UserLoaded(user: user));
      } else if (current is UserLoaded) {
        emit(UserError(message: 'User document not found'));
      }
    } catch (e) {
      if (current is UserLoaded) {
        emit(UserError(message: e.toString()));
      }
    }
  }
}
