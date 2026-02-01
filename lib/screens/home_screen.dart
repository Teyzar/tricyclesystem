// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_state.dart';
import 'tabs/qr_scanner_screen.dart';
import 'tabs/qr_code_screen.dart';
import 'tabs/profile_screen.dart';

/// Student or driver home. Role is determined by routing (main.dart) — no role logic here.
/// [role] is "student" or "driver" (lowercase from router).
class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! UserLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final screens = _getScreensForRole(widget.role, state);
        final navItems = _getNavItemsForRole(widget.role);

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: navItems,
          ),
        );
      },
    );
  }

  List<Widget> _getScreensForRole(String role, UserState userState) {
    final userName = _userName(userState);
    final roleLabel = _roleDisplayLabel(role);
    switch (role) {
      case 'student':
        return [
          _HomeContent(userName: userName, roleLabel: 'Student'),
          const QRScannerScreen(),
          const ProfileScreen(),
        ];
      case 'driver':
        return [
          _HomeContent(userName: userName, roleLabel: 'Driver'),
          const QRCodeScreen(),
          const ProfileScreen(),
        ];
      default:
        return [
          _HomeContent(userName: userName, roleLabel: roleLabel),
          const QRScannerScreen(),
          const ProfileScreen(),
        ];
    }
  }

  String _userName(UserState userState) {
    if (userState is UserLoaded) {
      final n = userState.user.name;
      return n != null && n.isNotEmpty ? n : userState.user.email;
    }
    return '';
  }

  String _roleDisplayLabel(String role) {
    switch (role) {
      case 'student':
        return 'Student';
      case 'driver':
        return 'Driver';
      case 'admin':
        return 'Admin';
      default:
        return role.isNotEmpty
            ? role[0].toUpperCase() + role.substring(1)
            : 'User';
    }
  }

  List<BottomNavigationBarItem> _getNavItemsForRole(String role) {
    switch (role) {
      case 'student':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan QR',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      case 'driver':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR Code'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan QR',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
    }
  }
}

class _HomeContent extends StatelessWidget {
  final String userName;
  final String roleLabel;

  const _HomeContent({required this.userName, required this.roleLabel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $roleLabel'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            userName,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '$roleLabel Dashboard',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (roleLabel == 'Student') _buildStudentQuickActions(context),
            if (roleLabel == 'Driver') _buildDriverQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentQuickActions(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.qr_code_scanner, color: Colors.blue),
        title: const Text('Scan Driver QR Code'),
        subtitle: const Text('Scan a driver\'s QR code to book a ride'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Switch to QR Scanner tab is handled by parent via index
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Use the Scan QR tab below')),
          );
        },
      ),
    );
  }

  Widget _buildDriverQuickActions(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.qr_code, color: Colors.blue),
        title: const Text('Show QR Code'),
        subtitle: const Text('Display your QR code for students to scan'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Use the QR Code tab below')),
          );
        },
      ),
    );
  }
}
