import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '_email_and_password_fields.dart';
import '_auth_button.dart';

class RegisterForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController plateNumberController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Function(String) selectedRole;
  final Function() handleAction;
  const RegisterForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.plateNumberController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.selectedRole,
    required this.handleAction,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  String _selectedRole = 'Student';
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.phoneController,
          decoration: InputDecoration(
            labelText: _selectedRole == 'Student'
                ? 'Emergency Contact No.'
                : _selectedRole == 'Admin'
                ? 'Phone Number'
                : 'Phone Number',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        if (_selectedRole == 'Driver') ...[
          TextField(
            controller: widget.plateNumberController,
            decoration: InputDecoration(
              labelText: 'Plate Number',
              prefixIcon: const Icon(Icons.car_rental_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 16),
        EmailAndPasswordFields(
          emailController: widget.emailController,
          passwordController: widget.passwordController,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          items: ['Student', 'Driver']
              .map((role) => DropdownMenuItem(value: role, child: Text(role)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              widget.selectedRole(value);
              setState(() {
                _selectedRole = value;
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'Role',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
        const SizedBox(height: 24),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return AuthButton(
              label: 'Register',
              isLoading: state is AuthLoading,
              onPressed: () {
                widget.handleAction();
                // TODO: Implement registration event
                // Example: context.read<AuthBloc>().add(RegisterEvent(...))
              },
            );
          },
        ),
      ],
    );
  }
}
