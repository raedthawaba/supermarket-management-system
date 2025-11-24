import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Initialize Firebase with development-safe configuration
Future<void> initializeFirebase() async {
  try {
    // Skip Firebase initialization in CI/testing environment
    const bool isCI = bool.fromEnvironment('CI', defaultValue: false);
    const bool skipFirebase = bool.fromEnvironment('FIREBASE_SKIP', defaultValue: false);
    const bool isVMProduct = bool.fromEnvironment('dart.vm.product', defaultValue: false);
    
    if (skipFirebase || isCI || isVMProduct) {
      print('Firebase initialization skipped (CI/Testing environment)');
      return;
    }

    // For local development, check if we have real Firebase config
    const FirebaseOptions options = DefaultFirebaseOptions.currentPlatform;
    
    // Check if this is a real Firebase project (not placeholder)
    final bool isRealConfig = 
        options.projectId != 'supermarket-system-placeholder' &&
        !options.apiKey.contains('Example') &&
        !options.apiKey.contains('placeholder') &&
        options.projectId.isNotEmpty;
    
    if (isRealConfig) {
      await Firebase.initializeApp(options: options);
      print('Firebase initialized successfully');
    } else {
      // Development mode - skip Firebase initialization
      print('Firebase initialization skipped (development mode - no real config)');
    }
  } catch (e) {
    // Continue even if Firebase fails
    print('Firebase initialization failed: $e - continuing without Firebase');
  }
}