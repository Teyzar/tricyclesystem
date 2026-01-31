// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'widgets/_login_form.dart';
import 'widgets/_register_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  bool _isRegister = false;

  Future<void> _onRegister() async {
    context.read<AuthBloc>().add(
      RegisterEvent(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        phone: _phoneController.text,
        role: _roleController.text,
        plateNumber: _plateNumberController.text,
      ),
    );
  }

  Future<void> _onLogin() async {
    context.read<AuthBloc>().add(
      LoginEvent(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  void _handleAction() {
    if (_isRegister) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Passwords do not match"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      _onRegister();
    } else {
      _onLogin();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isRegister
                      ? 'Registration Successful!'
                      : 'Login Successful!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isRegister
                                ? Icons.person_add_alt_1
                                : Icons.lock_outline,
                            size: 64,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _isRegister ? 'Create Account' : 'Welcome Back',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isRegister
                                ? 'Register to get started'
                                : 'Sign in to continue',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 32),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isRegister
                                ? RegisterForm(
                                    key: const ValueKey('register'),
                                    nameController: _nameController,
                                    phoneController: _phoneController,
                                    emailController: _emailController,
                                    plateNumberController:
                                        _plateNumberController,
                                    passwordController: _passwordController,
                                    confirmPasswordController:
                                        _confirmPasswordController,
                                    selectedRole: (value) {
                                      setState(() {
                                        _roleController.text = value;
                                      });
                                    },
                                    handleAction: _handleAction,
                                  )
                                : LoginForm(
                                    key: const ValueKey('login'),
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                  ),
                          ),
                          const SizedBox(height: 24),
                          // BlocBuilder<AuthBloc, AuthState>(
                          //   builder: (context, state) {
                          //     if (state is AuthLoading) {
                          //       return const CircularProgressIndicator();
                          //     }
                          //     return ElevatedButton(
                          //       style: ElevatedButton.styleFrom(
                          //         padding: const EdgeInsets.symmetric(
                          //           horizontal: 80,
                          //           vertical: 16,
                          //         ),
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(30),
                          //         ),
                          //       ),
                          //       onPressed: _handleAction,
                          //       child: Text(_isRegister ? 'Register' : 'Login'),
                          //     );
                          //   },
                          // ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isRegister = !_isRegister;
                              });
                            },
                            child: Text(
                              _isRegister
                                  ? 'Already have an account? Login'
                                  : 'Do you have an account? Register here',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          if (!_isRegister) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password
                              },
                              child: const Text('Forgot Password?'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
