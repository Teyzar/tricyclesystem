import 'package:flutter/material.dart';
import '../data/models/user_model.dart';

class UserInfo extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserInfo({super.key, required this.user, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    user.name?.isNotEmpty == true
                        ? user.name![0].toUpperCase()
                        : user.email[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name ?? 'No Name',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role ?? 'Unknown Role',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // User Details Card
          Card(
            child: Column(
              children: [
                if (user.phone != null && user.phone!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Phone Number'),
                    subtitle: Text(user.phone!),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                if (user.phone != null && user.phone!.isNotEmpty)
                  const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email Address'),
                  subtitle: Text(user.email),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Driver-specific information
          if (user.role?.toLowerCase() == 'driver') ...[
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.directions_car,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('Driver Information'),
                    titleTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  if (user.plateNumber != null &&
                      user.plateNumber!.isNotEmpty) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.confirmation_number),
                      title: const Text('Plate Number'),
                      subtitle: Text(user.plateNumber!),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                  if (user.status != null && user.status!.isNotEmpty) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('Status'),
                      subtitle: Text(user.status!),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Status for non-drivers
          if (user.status != null &&
              user.status!.isNotEmpty &&
              user.role?.toLowerCase() != 'driver')
            Card(
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Status'),
                subtitle: Text(user.status!),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),

          // Action Buttons
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(height: 24),
            if (onEdit != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (onEdit != null && onDelete != null) const SizedBox(height: 12),
            if (onDelete != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
