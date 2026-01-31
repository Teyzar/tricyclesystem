import '../models/request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsRepository {
  // Mock data for demonstration - replace with actual API calls
  final _auth = FirebaseAuth.instance;

  final List<RequestModel> _mockRequests = [
    RequestModel(
      id: '1',
      driverName: 'Mike Johnson',
      driverEmail: 'mike.johnson@example.com',
      plateNumber: 'ABC123',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RequestModel(
      id: '2',
      driverName: 'Sarah Wilson',
      driverEmail: 'sarah.wilson@example.com',
      plateNumber: 'XYZ789',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    RequestModel(
      id: '3',
      driverName: 'Mike Johnson',
      driverEmail: 'mike.johnson@example.com',
      plateNumber: 'ABC123',
      status: 'approved',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  Future<List<RequestModel>> getAllRequests() async {
    // Simulate API delay
    final requests = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isNotEqualTo: 'Admin')
        .get();

    return requests.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return RequestModel.fromJson(data);
    }).toList();
  }

  Future<RequestModel> approveRequest(String requestId) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(requestId);

    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      throw Exception('Request not found');
    }

    await docRef.update({
      'status': 'Approved',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updatedDoc = await docRef.get();
    final data = updatedDoc.data();
    if (data == null) {
      throw Exception('Failed to fetch updated request');
    }
    data['id'] = updatedDoc.id;

    if (data['updatedAt'] != null && data['updatedAt'] is Timestamp) {
      data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate();
    }

    return RequestModel.fromJson(data);
  }

  Future<RequestModel> rejectRequest(String requestId) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(requestId);

    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      throw Exception('Request not found');
    }

    await docRef.update({
      'status': 'Rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updatedDoc = await docRef.get();
    final data = updatedDoc.data();
    if (data == null) {
      throw Exception('Failed to fetch updated request');
    }
    data['id'] = updatedDoc.id;

    if (data['updatedAt'] != null && data['updatedAt'] is Timestamp) {
      data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate();
    }

    return RequestModel.fromJson(data);
  }

  Future<RequestModel> completeRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _mockRequests.indexWhere(
      (request) => request.id == requestId,
    );
    if (index != -1) {
      final updatedRequest = _mockRequests[index].copyWith(
        status: 'completed',
        updatedAt: DateTime.now(),
      );
      _mockRequests[index] = updatedRequest;
      return updatedRequest;
    }
    throw Exception('Request not found');
  }

  Future<RequestModel> createRequest(RequestModel request) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final newRequest = request.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      status: 'pending',
    );
    _mockRequests.add(newRequest);
    return newRequest;
  }
}
