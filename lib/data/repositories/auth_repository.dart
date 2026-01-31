import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('User not found');
      }

      final userData = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      var data = UserModel(
        id: firebaseUser.uid,
        email: email,
        name: userData['name'],
        phone: userData['phone'],
        role: userData['role'],
      );

      if (data.plateNumber != null || data.status != null) {
        data.plateNumber = userData['plateNumber'];
        data.status = userData['status'];
      }

      return data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<UserModel> register(UserModel userModel) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: userModel.password ?? '',
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('User creation failed');
      }
      final userData = {
        'email': userModel.email,
        'name': userModel.name,
        'phone': userModel.phone,
        'role': userModel.role,
        'createdAt': userModel.createdAt,
        'updatedAt': userModel.updatedAt,
      };

      if (userModel.role == 'Driver') {
        userData['plateNumber'] = userModel.plateNumber;
        userData['status'] = 'Pending';
      }

      await _firestore.collection('users').doc(firebaseUser.uid).set(userData);

      return UserModel(
        id: firebaseUser.uid,
        email: userModel.email,
        name: userModel.name,
        phone: userModel.phone,
        role: userModel.role,
        plateNumber: userModel.role == 'Driver' ? userModel.plateNumber : null,
        status: userModel.role == 'Driver' ? 'Pending' : null,
        createdAt: userModel.createdAt,
        updatedAt: userModel.updatedAt,
      );
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
}
