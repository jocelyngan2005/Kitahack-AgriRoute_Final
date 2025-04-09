// auth_service.dart - Extended with getUserType method
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _userType;
  
  bool get isLoggedIn => _user != null;
  User? get user => _user;
  String? get userType => _userType;
  
  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        _userType = await getUserType();
      } else {
        _userType = null;
      }
      notifyListeners();
    });
  }
  
  Future<String?> getUserType() async {
    try {
      if (_user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          return userData['userType'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting user type: $e');
      return null;
    }
  }
  
  Future<UserCredential> signUp(String name, String email, String password, String userType) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'userType': userType,
        });

        await userCredential.user!.updateDisplayName(name);
        _userType = userType;
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        _userType = await getUserType();
      }
      
      return credential;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
    _userType = null;
  }
}