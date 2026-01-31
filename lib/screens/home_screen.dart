// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import 'tabs/qr_scanner_screen.dart';
import 'tabs/qr_code_screen.dart';
import 'tabs/users_screen.dart';
import 'tabs/profile_screen.dart';
import 'tabs/requests_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final userRole = state.user.role ?? 'Student';
          final screens = _getScreensForRole(userRole);
          final bottomNavItems = _getBottomNavItemsForRole(userRole);

          return Scaffold(
            body: IndexedStack(index: _currentIndex, children: screens),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              items: bottomNavItems,
            ),
          );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  List<Widget> _getScreensForRole(String role) {
    switch (role) {
      case 'Student':
        return [
          _buildHomeContent('Student'),
          const QRScannerScreen(),
          const ProfileScreen(),
        ];
      case 'Driver':
        return [
          _buildHomeContent('Driver'),
          const QRCodeScreen(),
          const ProfileScreen(),
        ];
      case 'Admin':
        return [
          _buildHomeContent('Admin'),
          const UsersScreen(),
          const RequestsScreen(),
          const ProfileScreen(),
        ];
      default:
        return [
          _buildHomeContent('Student'),
          const QRScannerScreen(),
          const ProfileScreen(),
        ];
    }
  }

  List<BottomNavigationBarItem> _getBottomNavItemsForRole(String role) {
    switch (role) {
      case 'Student':
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan QR',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      case 'Driver':
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR Code',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      case 'Admin':
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions_outlined),
            label: 'Requests',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      default:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan QR',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
    }
  }

  Widget _buildHomeContent(String role) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $role'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  user.name?.isNotEmpty == true
                                      ? user.name![0].toUpperCase()
                                      : user.email[0].toUpperCase(),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      user.name ?? 'User',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Role-specific content
                  if (role == 'Student') ...[
                    _buildStudentContent(),
                  ] else if (role == 'Driver') ...[
                    _buildDriverContent(),
                  ] else if (role == 'Admin') ...[
                    _buildAdminContent(),
                  ],

                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActions(role),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStudentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student Dashboard',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.qr_code_scanner, color: Colors.blue),
            title: const Text('Scan Driver QR Code'),
            subtitle: const Text('Scan a driver\'s QR code to book a ride'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              setState(() {
                _currentIndex = 1; // Switch to QR Scanner
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.green),
            title: const Text('Ride History'),
            subtitle: const Text('View your previous rides'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ride history coming soon!')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDriverContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Driver Dashboard',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.qr_code, color: Colors.blue),
            title: const Text('Show QR Code'),
            subtitle: const Text('Display your QR code for students to scan'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              setState(() {
                _currentIndex = 1; // Switch to QR Code
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.directions_car, color: Colors.green),
            title: const Text('Active Rides'),
            subtitle: const Text('View current and pending rides'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Active rides coming soon!')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdminContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Dashboard',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.people, color: Colors.blue),
            title: const Text('Manage Users'),
            subtitle: const Text('View and manage all users'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              setState(() {
                _currentIndex = 1; // Switch to Users
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.analytics, color: Colors.green),
            title: const Text('Analytics'),
            subtitle: const Text('View system statistics and reports'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analytics coming soon!')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(String role) {
    List<Map<String, dynamic>> actions = [];

    switch (role) {
      case 'Student':
        actions = [
          {
            'icon': Icons.qr_code_scanner,
            'title': 'Scan QR',
            'color': Colors.blue,
          },
          {'icon': Icons.history, 'title': 'History', 'color': Colors.green},
          {'icon': Icons.settings, 'title': 'Settings', 'color': Colors.orange},
        ];
        break;
      case 'Driver':
        actions = [
          {'icon': Icons.qr_code, 'title': 'QR Code', 'color': Colors.blue},
          {
            'icon': Icons.directions_car,
            'title': 'Rides',
            'color': Colors.green,
          },
          {'icon': Icons.settings, 'title': 'Settings', 'color': Colors.orange},
        ];
        break;
      case 'Admin':
        actions = [
          {'icon': Icons.people, 'title': 'Users', 'color': Colors.blue},
          {
            'icon': Icons.analytics,
            'title': 'Analytics',
            'color': Colors.green,
          },
          {'icon': Icons.settings, 'title': 'Settings', 'color': Colors.orange},
        ];
        break;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return Card(
          child: InkWell(
            onTap: () {
              if (action['title'] == 'Scan QR' ||
                  action['title'] == 'QR Code' ||
                  action['title'] == 'Users') {
                setState(() {
                  _currentIndex = 1; // Switch to the appropriate screen
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${action['title']} coming soon!')),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action['icon'], size: 32, color: action['color']),
                const SizedBox(height: 8),
                Text(
                  action['title'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
