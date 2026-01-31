import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import '_email_and_password_fields.dart';
import '_auth_button.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmailAndPasswordFields(
          emailController: emailController,
          passwordController: passwordController,
        ),
        const SizedBox(height: 24),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return AuthButton(
              label: 'Sign In',
              isLoading: state is AuthLoading,
              onPressed: () {
                context.read<AuthBloc>().add(
                  LoginEvent(
                    email: emailController.text,
                    password: passwordController.text,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
