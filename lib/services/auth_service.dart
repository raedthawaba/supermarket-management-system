import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _userFromFirebaseUser(User? user) {
    return user != null
        ? UserModel(
            id: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? user.email?.split('@')[0] ?? '',
            role: UserRole.cashier, // Default role
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        : null;
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return _userFromFirebaseUser(user);
    }
    return null;
  }

  Future<UserModel> signIn(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final UserModel? user = _userFromFirebaseUser(result.user);
      if (user == null) {
        throw 'فشل في تسجيل الدخول';
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني';
        case 'wrong-password':
          throw 'كلمة المرور غير صحيحة';
        case 'user-disabled':
          throw 'تم تعطيل هذا المستخدم';
        case 'too-many-requests':
          throw 'محاولات كثيرة، يرجى المحاولة لاحقاً';
        default:
          throw 'خطأ في تسجيل الدخول: ${e.message}';
      }
    } catch (e) {
      throw 'خطأ غير متوقع: $e';
    }
  }

  Future<UserModel> signUp(String email, String password, String name) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await result.user?.updateDisplayName(name);
      
      // Create user document in Firestore
      final userModel = UserModel(
        id: result.user!.uid,
        email: email,
        name: name,
        role: UserRole.cashier, // Default role
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(result.user!.uid).set(
        userModel.toJson(),
      );
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'البريد الإلكتروني مستخدم بالفعل';
        case 'weak-password':
          throw 'كلمة المرور ضعيفة جداً';
        case 'invalid-email':
          throw 'البريد الإلكتروني غير صحيح';
        default:
          throw 'خطأ في إنشاء الحساب: ${e.message}';
      }
    } catch (e) {
      throw 'خطأ غير متوقع: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني';
        default:
          throw 'خطأ في إعادة تعيين كلمة المرور: ${e.message}';
      }
    }
  }

  Future<void> updateUserProfile(String name, String? phone) async {
    final user = _auth.currentUser;
    if (user == null) throw 'المستخدم غير مسجل الدخول';

    try {
      await user.updateDisplayName(name);
      
      final userData = {
        'name': name,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection('users').doc(user.uid).update(userData);
    } catch (e) {
      throw 'فشل في تحديث الملف الشخصي: $e';
    }
  }
}