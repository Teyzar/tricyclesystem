import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/requests/requests_bloc.dart';
import '../../blocs/requests/requests_event.dart';
import '../../blocs/requests/requests_state.dart';
import '../../data/models/request_model.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<RequestsBloc>().add(const LoadRequests());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Registration Requests'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
          ],
        ),
      ),
      body: BlocConsumer<RequestsBloc, RequestsState>(
        listener: (context, state) {
          if (state is RequestActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Driver registration ${state.action} successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is RequestActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RequestsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RequestsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading driver registrations',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RequestsBloc>().add(const LoadRequests());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is RequestsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(state.requests, 'all'),
                _buildRequestsList(
                  state.requests
                      .where((r) => (r.status).toLowerCase() == 'pending')
                      .toList(),
                  'pending',
                ),
                _buildRequestsList(
                  state.requests
                      .where((r) => (r.status).toLowerCase() == 'approved')
                      .toList(),
                  'approved',
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildRequestsList(List<RequestModel> requests, String filter) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              filter == 'pending' ? Icons.pending_actions : Icons.person_add,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${filter == 'all' ? '' : filter} driver registrations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              filter == 'pending'
                  ? 'No pending driver registrations to approve'
                  : 'No driver registrations found',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<RequestsBloc>().add(const RefreshRequests());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(RequestModel request) {
    final statusColor = _getStatusColor(request.status);
    final statusIcon = _getStatusIcon(request.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        request.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateTime(request.createdAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Driver information
            _buildDriverInfo(request),
            const SizedBox(height: 16),

            // Notes
            // if (request.notes != null && request.notes!.isNotEmpty) ...[
            //   Container(
            //     padding: const EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       color: Colors.grey[50],
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Row(
            //       children: [
            //         Icon(Icons.note, size: 16, color: Colors.grey[600]),
            //         const SizedBox(width: 8),
            //         Expanded(
            //           child: Text(
            //             request.notes!,
            //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            //               color: Colors.grey[700],
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            //   const SizedBox(height: 16),
            // ],

            // Action buttons
            if ((request.status).toLowerCase() == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(request.id!),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectRequest(request.id!),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject Driver'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (request.status == 'approved') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _completeRequest(request.id!),
                  icon: const Icon(Icons.done_all, size: 16),
                  label: const Text('Mark as Active'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfo(RequestModel request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_add, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Driver Registration',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Driver details
          _buildInfoRow('Name', request.driverName, Icons.person),
          const SizedBox(height: 8),
          _buildInfoRow('Email', request.driverEmail, Icons.email),
          const SizedBox(height: 8),
          if (request.plateNumber != null &&
              request.plateNumber!.isNotEmpty) ...[
            _buildInfoRow(
              'Plate Number',
              request.plateNumber!,
              Icons.directions_car,
            ),
            const SizedBox(height: 8),
          ],

          // Student who requested (if applicable)
          // if (request.studentName.isNotEmpty) ...[
          //   const Divider(),
          //   const SizedBox(height: 8),
          //   Row(
          //     children: [
          //       Icon(Icons.school, size: 16, color: Colors.grey[600]),
          //       const SizedBox(width: 8),
          //       Text(
          //         'Requested by:',
          //         style: TextStyle(
          //           color: Colors.grey[600],
          //           fontWeight: FontWeight.w500,
          //           fontSize: 12,
          //         ),
          //       ),
          //     ],
          //   ),
          //   const SizedBox(height: 4),
          //   Padding(
          //     padding: const EdgeInsets.only(left: 24),
          //     child: Text(
          //       '${request.studentName} (${request.studentEmail})',
          //       style: Theme.of(
          //         context,
          //       ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _approveRequest(String requestId) {
    debugPrint('requestId: $requestId');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Driver Registration'),
        content: const Text(
          'Are you sure you want to approve this driver registration? This will allow the driver to start accepting ride requests.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<RequestsBloc>().add(ApproveRequest(requestId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectRequest(String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Driver Registration'),
        content: const Text(
          'Are you sure you want to reject this driver registration? This will prevent the driver from accessing the platform.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<RequestsBloc>().add(RejectRequest(requestId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _completeRequest(String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Driver'),
        content: const Text(
          'Are you sure you want to mark this driver as active? This will enable them to receive ride requests.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<RequestsBloc>().add(CompleteRequest(requestId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }
}
