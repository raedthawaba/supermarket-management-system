import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supermarket_system_phase1/models/user.dart';
import 'package:supermarket_system_phase1/models/product.dart';
import 'package:supermarket_system_phase1/models/category.dart';
import 'package:supermarket_system_phase1/models/transaction.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth methods
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  // Get current user profile from Firestore
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      if (_auth.currentUser == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // User methods
  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
    );
  }

  Future<void> createUser(UserModel user, String password) async {
    try {
      // Create user in Firebase Auth
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      // Create user document in Firestore
      UserModel newUser = UserModel(
        uid: authResult.user!.uid,
        email: user.email,
        name: user.name,
        role: user.role,
      );

      await _firestore
          .collection('users')
          .doc(authResult.user!.uid)
          .set(newUser.toFirestore());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Product methods
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<Product>> searchProducts(String query) {
    return _firestore
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<void> createProduct(Product product) async {
    try {
      await _firestore.collection('products').add(product.toFirestore());
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      if (product.id == null) throw Exception('Product ID is required');
      await _firestore.collection('products').doc(product.id).update(product.toFirestore());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product stock: $e');
    }
  }

  // Category methods
  Stream<List<Category>> getCategories() {
    return _firestore.collection('categories').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList(),
    );
  }

  Future<void> createCategory(Category category) async {
    try {
      await _firestore.collection('categories').add(category.toFirestore());
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      if (category.id == null) throw Exception('Category ID is required');
      await _firestore.collection('categories').doc(category.id).update(category.toFirestore());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Transaction methods
  Stream<List<Transaction>> getTransactions({int limit = 50}) {
    return _firestore.collection('transactions').orderBy('createdAt', descending: true).limit(limit).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<Transaction>> getTodayTransactions() {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    
    return _firestore
        .collection('transactions')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList());
  }

  Future<void> createTransaction(Transaction transaction) async {
    try {
      await _firestore.collection('transactions').add(transaction.toFirestore());
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  Future<void> completeSaleTransaction(Transaction transaction) async {
    try {
      WriteBatch batch = _firestore.batch();

      // Create transaction document
      DocumentReference transactionRef = _firestore.collection('transactions').doc();
      batch.set(transactionRef, transaction.toFirestore());

      // Update product stocks
      for (TransactionItem item in transaction.items) {
        DocumentReference productRef = _firestore.collection('products').doc(item.productId);
        batch.update(productRef, {
          'stock': FieldValue.increment(-item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to complete sale: $e');
    }
  }

  // Error handling
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'بريد إلكتروني غير صحيح';
      default:
        return 'حدث خطأ في تسجيل الدخول';
    }
  }
}

// UserModel alias to avoid conflicts
class UserModel extends User {}