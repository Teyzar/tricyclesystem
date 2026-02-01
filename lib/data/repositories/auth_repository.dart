import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Single source of truth for Firebase Auth.
/// Firestore user documents are read via [getUserDocument] (used by UserBloc).
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of auth state — use this to sync BLoC with Firebase (e.g. on app start / sign out elsewhere).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password. Does not return UserModel — UserBloc will load it.
  Future<String> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('Login failed: no user returned');
    return user.uid;
  }

  /// Create Firebase account and Firestore user document. Returns new user's uid.
  /// Role/status stored in Firestore as lowercase: "student" | "driver" | "admin", "pending" | "approved" | "rejected".
  Future<String> register(UserModel userModel) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: userModel.email,
      password: userModel.password ?? '',
    );
    final user = credential.user;
    if (user == null) throw Exception('User creation failed');

    final role = _normalizeRole(userModel.role);
    final userData = <String, dynamic>{
      'uid': user.uid,
      'email': userModel.email,
      'name': userModel.name,
      'phone': userModel.phone,
      'role': role,
      'createdAt': userModel.createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (role == 'driver') {
      userData['plateNumber'] = userModel.plateNumber;
      userData['status'] = 'pending';
    } else {
      userData['status'] = 'approved'; // student/admin are effectively approved
    }

    await _firestore.collection('users').doc(user.uid).set(userData);
    return user.uid;
  }

  /// Get Firestore user document. Returns null if doc does not exist (e.g. corrupted state).
  Future<UserModel?> getUserDocument(String uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    final data = snap.data()!;
    return _userModelFromMap(uid, data);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  static String? _normalizeRole(String? role) {
    if (role == null || role.isEmpty) return null;
    return role.toLowerCase();
  }

  static UserModel _userModelFromMap(String id, Map<String, dynamic> data) {
    final role = _normalizeRole(data['role'] as String?);
    final status = (data['status'] as String?)?.toLowerCase();
    return UserModel(
      id: id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String?,
      phone: data['phone'] as String?,
      role: role,
      plateNumber: data['plateNumber'] as String?,
      status: status,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }
}
