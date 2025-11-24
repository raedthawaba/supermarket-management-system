import 'package:supermarket_system_phase1/models/user.dart';
import 'package:supermarket_system_phase1/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isStaff => _currentUser?.isStaff ?? false;

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      final result = await _firebaseService.signIn(email, password);
      if (result != null) {
        _currentUser = await _firebaseService.getCurrentUserProfile();
        await _saveUserToPreferences(_currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('فشل في تسجيل الدخول: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      _currentUser = null;
      await _clearPreferences();
    } catch (e) {
      throw Exception('فشل في تسجيل الخروج: $e');
    }
  }

  // Load user from preferences (for auto-login)
  Future<void> loadUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null) {
        // Set the user directly without auth verification for demo
        // In production, you'd verify with Firebase Auth
        await _getUserById(userId);
      }
    } catch (e) {
      print('Error loading user from preferences: $e');
    }
  }

  // Save user to preferences
  Future<void> _saveUserToPreferences(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.uid);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_role', user.role);
    await prefs.setBool('is_logged_in', true);
  }

  // Clear preferences
  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get user by ID (simplified for demo)
  Future<void> _getUserById(String userId) async {
    try {
      // This would typically fetch from Firestore
      // For now, we'll create a mock user based on saved preferences
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email') ?? '';
      final name = prefs.getString('user_name') ?? '';
      final role = prefs.getString('user_role') ?? 'staff';
      
      _currentUser = UserModel(
        uid: userId,
        email: email,
        name: name,
        role: role,
      );
    } catch (e) {
      print('Error getting user by ID: $e');
    }
  }

  // Create new user (admin only)
  Future<void> createUser(String email, String password, String name, String role) async {
    try {
      UserModel newUser = UserModel(
        uid: '', // Will be set by Firebase
        email: email,
        name: name,
        role: role,
      );

      await _firebaseService.createUser(newUser, password);
    } catch (e) {
      throw Exception('فشل في إنشاء المستخدم: $e');
    }
  }

  // Update current user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firebaseService.updateUserProfile(user);
      _currentUser = user;
      await _saveUserToPreferences(user);
    } catch (e) {
      throw Exception('فشل في تحديث المستخدم: $e');
    }
  }

  // Check if user has required role
  bool hasRole(String role) {
    if (_currentUser == null) return false;
    
    if (role == 'admin') {
      return _currentUser!.isAdmin;
    } else if (role == 'staff') {
      return _currentUser!.isStaff || _currentUser!.isAdmin;
    }
    
    return false;
  }

  // Check permissions
  bool get canManageProducts => hasRole('admin');
  bool get canManageUsers => hasRole('admin');
  bool get canViewReports => hasRole('admin');
  bool get canManageSettings => hasRole('admin');
  bool get canDeleteProducts => hasRole('admin');

  @override
  String toString() {
    return 'AuthService(isLoggedIn: $isLoggedIn, user: $_currentUser)';
  }
}