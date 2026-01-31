// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tricyclesystem/blocs/auth/auth_state.dart';
import 'package:tricyclesystem/screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/requests/requests_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/requests_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AuthRepository authRepository = AuthRepository();
  final RequestsRepository requestsRepository = RequestsRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<RequestsBloc>(
          create: (context) =>
              RequestsBloc(requestsRepository: requestsRepository),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isAuthenticated =
              state is AuthAuthenticated ||
              _auth.currentUser !=
                  null; // Fixed: Changed from Authenticated to AuthAuthenticated

          debugPrint('isAuthenticated: $isAuthenticated');

          // _auth.signOut();

          final GoRouter router = GoRouter(
            initialLocation: '/login',
            redirect: (context, state) {
              // If not authenticated, always go to login

              if (isAuthenticated) {
                return '/home';
              }

              if (!isAuthenticated && state.fullPath != '/login') {
                return '/login';
              }

              // If authenticated, prevent going back to login
              if (isAuthenticated && state.fullPath == '/login') {
                return '/home';
              }
            },
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => LoginScreen(),
              ),
              GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
            ],
          );

          return MaterialApp.router(routerConfig: router);
        },
      ),
    );
  }
}
