import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

/// Handles Firebase Auth state only. Single source of truth for "is user signed in?".
/// User profile (role, status) is in [UserBloc].
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription? _authSubscription;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    _authSubscription = authRepository.authStateChanges.listen((user) {
      if (user != null) {
        add(_AuthUserChanged(uid: user.uid));
      } else {
        add(_AuthUserChanged(uid: null));
      }
    });
    on<_AuthUserChanged>(_onAuthUserChanged);
  }

  void _onAuthUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.uid != null) {
      emit(AuthAuthenticated(uid: event.uid!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final uid = await authRepository.login(event.email, event.password);
      emit(AuthAuthenticated(uid: uid));
    } catch (e) {
      emit(AuthError(errorMessage: e.toString()));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userAuth = UserModel(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
        role: event.role,
        plateNumber: event.plateNumber,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      final uid = await authRepository.register(userAuth);
      emit(AuthAuthenticated(uid: uid));
    } catch (e) {
      emit(AuthError(errorMessage: e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}

/// Internal event: Firebase auth state changed (e.g. app start, sign out).
class _AuthUserChanged extends AuthEvent {
  final String? uid;
  _AuthUserChanged({this.uid});
  @override
  List<Object?> get props => [uid];
}
