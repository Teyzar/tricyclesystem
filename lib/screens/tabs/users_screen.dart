import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tricyclesystem/data/models/user_model.dart';
import '../../widgets/user_info.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final FirebaseFirestore user = FirebaseFirestore.instance;
    final users = user
        .collection('users')
        .where('status', isEqualTo: 'Approved')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add user functionality coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading users: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          final users = snapshot.data!.docs;

          final countUsers = users
              .where((user) => user['status'] == 'Approved')
              .length;

          if (countUsers == 0) {
            return const Center(
              child: Text(
                'No users found.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      (userData['name'] ?? 'U').toString().isNotEmpty
                          ? userData['name'][0]
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    userData['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(userData['email'] ?? 'No email'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: userData['role'] == 'Student'
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      userData['role'] ?? 'Unknown',
                      style: TextStyle(
                        color: userData['role'] == 'Student'
                            ? Colors.blue[700]
                            : Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  onTap: () {
                    // TODO: Implement user details/edit functionality

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: UserInfo(
                          user: UserModel(
                            email: userData['email'],
                            name: userData['name'],
                            role: userData['role'],
                            plateNumber: userData['plateNumber'],
                            phone: userData['phone'],
                            status: userData['status'],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
