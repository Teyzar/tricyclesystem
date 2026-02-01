// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tricyclesystem/blocs/auth/auth_bloc.dart';
import 'package:tricyclesystem/blocs/auth/auth_event.dart';
import 'package:tricyclesystem/blocs/auth/auth_state.dart';
import 'package:tricyclesystem/blocs/user/user_bloc.dart';
import 'package:tricyclesystem/blocs/user/user_event.dart';
import 'package:tricyclesystem/blocs/user/user_state.dart';
import 'package:tricyclesystem/blocs/requests/requests_bloc.dart';
import 'package:tricyclesystem/data/repositories/auth_repository.dart';
import 'package:tricyclesystem/data/repositories/requests_repository.dart';
import 'package:tricyclesystem/screens/auth/login_screen.dart';
import 'package:tricyclesystem/screens/home_screen.dart';
import 'package:tricyclesystem/screens/driver_pending_screen.dart';
import 'package:tricyclesystem/screens/admin_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthRepository authRepository = AuthRepository();
  final RequestsRepository requestsRepository = RequestsRepository();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<UserBloc>(
          create: (_) => UserBloc(authRepository: authRepository),
        ),
        BlocProvider<RequestsBloc>(
          create: (_) => RequestsBloc(requestsRepository: requestsRepository),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          final userBloc = context.read<UserBloc>();
          if (authState is AuthAuthenticated) {
            userBloc.add(UserLoadRequested(authState.uid));
          } else if (authState is AuthUnauthenticated ||
              authState is AuthInitial) {
            userBloc.add(UserClearRequested());
          }
        },
        child: BlocListener<UserBloc, UserState>(
          listenWhen: (prev, curr) => curr is UserError,
          listener: (context, userState) {
            // If loading user profile fails (e.g. Firestore/Google API error), sign out
            // so user isn't stuck on loading and can try again or fix config.
            context.read<AuthBloc>().add(LogoutEvent());
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (prev, curr) => true,
            builder: (context, authState) {
              return BlocBuilder<UserBloc, UserState>(
                buildWhen: (prev, curr) => true,
                builder: (context, userState) {
                  final router = GoRouter(
                    initialLocation: '/login',
                    redirect: (context, goState) {
                      // Single source of truth: AuthBloc (no FirebaseAuth in UI)
                      if (authState is AuthInitial ||
                          authState is AuthUnauthenticated ||
                          authState is AuthError) {
                        return goState.fullPath == '/login' ? null : '/login';
                      }
                      if (authState is AuthLoading) return null;
                      if (authState is AuthAuthenticated) {
                        if (userState is UserInitial ||
                            userState is UserLoading ||
                            userState is UserError) {
                          return '/loading';
                        }
                        if (userState is UserUnauthenticated) return '/login';
                        if (userState is UserLoaded) {
                          final u = userState.user;
                          final role = (u.role ?? '').toLowerCase();
                          final status = (u.status ?? '').toLowerCase();
                          if (role == 'student') {
                            return goState.fullPath == '/home' ? null : '/home';
                          }
                          if (role == 'driver') {
                            if (status == 'pending') {
                              return goState.fullPath == '/driver-pending'
                                  ? null
                                  : '/driver-pending';
                            }
                            return goState.fullPath == '/driver-home'
                                ? null
                                : '/driver-home';
                          }
                          if (role == 'admin') {
                            return goState.fullPath == '/admin'
                                ? null
                                : '/admin';
                          }
                          return '/login';
                        }
                      }
                      return null;
                    },
                    routes: [
                      GoRoute(
                        path: '/login',
                        builder: (_, __) => const LoginScreen(),
                      ),
                      GoRoute(
                        path: '/loading',
                        builder: (_, __) => const _LoadingScreen(),
                      ),
                      GoRoute(
                        path: '/home',
                        builder: (_, __) => const HomeScreen(role: 'student'),
                      ),
                      GoRoute(
                        path: '/driver-pending',
                        builder: (_, __) => const DriverPendingScreen(),
                      ),
                      GoRoute(
                        path: '/driver-home',
                        builder: (_, __) => const HomeScreen(role: 'driver'),
                      ),
                      GoRoute(
                        path: '/admin',
                        builder: (_, __) => const AdminScreen(),
                      ),
                    ],
                  );
                  return MaterialApp.router(routerConfig: router);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Loading screen with escape hatch so user isn't stuck (e.g. if Firestore fails).
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Loading your profile…',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
