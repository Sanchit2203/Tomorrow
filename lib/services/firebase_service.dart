import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Check if Firebase is initialized
  bool get isInitialized => Firebase.apps.isNotEmpty;

  // Check Firebase services status
  Future<Map<String, bool>> checkServicesStatus() async {
    Map<String, bool> status = {
      'core': false,
      'auth': false,
      'firestore': false,
      'storage': false,
    };

    try {
      // Check Firebase Core
      if (Firebase.apps.isNotEmpty) {
        status['core'] = true;
      }

      // Check Firebase Auth
      try {
        FirebaseAuth.instance;
        status['auth'] = true;
      } catch (e) {
        print('Firebase Auth error: $e');
        status['auth'] = false;
      }

      // Check Firestore
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        // Try to connect to Firestore
        await firestore.disableNetwork();
        await firestore.enableNetwork();
        status['firestore'] = true;
      } catch (e) {
        print('Firestore error: $e');
        status['firestore'] = false;
      }

      // Check Firebase Storage
      try {
        FirebaseStorage.instance;
        status['storage'] = true;
      } catch (e) {
        print('Firebase Storage error: $e');
        status['storage'] = false;
      }
    } catch (e) {
      print('Firebase services check error: $e');
    }

    return status;
  }

  // Test Firebase connection
  Future<bool> testConnection() async {
    try {
      if (!isInitialized) {
        print('Firebase is not initialized');
        return false;
      }

      // Test Firestore connection
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('test').limit(1).get();
      
      print('Firebase connection test successful');
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }

  // Get Firebase configuration info
  Map<String, String> getConfigInfo() {
    Map<String, String> config = {};
    
    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseApp app = Firebase.app();
        config['name'] = app.name;
        config['projectId'] = app.options.projectId;
        config['appId'] = app.options.appId;
        config['apiKey'] = app.options.apiKey.substring(0, 10) + '...'; // Partial for security
      } else {
        config['status'] = 'Not initialized';
      }
    } catch (e) {
      config['error'] = e.toString();
    }

    return config;
  }

  // Initialize Firebase with error handling
  static Future<bool> initializeFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
        print('Firebase initialized successfully');
      } else {
        print('Firebase already initialized');
      }
      return true;
    } catch (e) {
      print('Firebase initialization failed: $e');
      return false;
    }
  }
}