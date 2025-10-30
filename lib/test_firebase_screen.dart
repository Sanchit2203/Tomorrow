import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestFirebaseScreen extends StatefulWidget {
  const TestFirebaseScreen({super.key});

  @override
  State<TestFirebaseScreen> createState() => _TestFirebaseScreenState();
}

class _TestFirebaseScreenState extends State<TestFirebaseScreen> {
  String _testResult = 'Tap button to test Firebase connection';
  bool _isLoading = false;

  Future<void> _testFirebaseConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing Firebase connection...';
    });

    try {
      // Test Firebase Auth
      User? currentUser = FirebaseAuth.instance.currentUser;
      print('Current user: ${currentUser?.uid}');
      
      if (currentUser == null) {
        setState(() {
          _testResult = 'No authenticated user found. Please login first.';
          _isLoading = false;
        });
        return;
      }

      // Test Firestore connection
      print('Testing Firestore connection...');
      
      // Try to write a test document
      DocumentReference testDoc = FirebaseFirestore.instance
          .collection('test')
          .doc('connection_test');
      
      await testDoc.set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection test',
        'user': currentUser.uid,
      });
      
      print('Test document written successfully');
      
      // Try to read the test document
      DocumentSnapshot snapshot = await testDoc.get();
      print('Test document read successfully: ${snapshot.exists}');
      
      // Try to write to users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
        'email': currentUser.email,
        'testField': 'Firebase connection test',
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('Users collection write successful');
      
      setState(() {
        _testResult = '''✅ Firebase Connection Test PASSED!

📊 Test Results:
• Firebase Auth: ✅ Connected
• Current User: ${currentUser.email}
• Firestore Write: ✅ Success
• Firestore Read: ✅ Success
• Users Collection: ✅ Accessible

🎉 Firebase is working correctly!''';
        _isLoading = false;
      });
      
    } catch (e) {
      print('Firebase test error: $e');
      setState(() {
        _testResult = '''❌ Firebase Connection Test FAILED!

Error: $e

💡 Possible solutions:
1. Check Firestore security rules
2. Verify Firebase project configuration
3. Ensure user is authenticated
4. Check internet connection''';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connection Test'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase Connection Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will test the connection to Firebase Auth, Firestore, and check if we can read/write data.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testFirebaseConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Testing...'),
                      ],
                    )
                  : const Text(
                      'Test Firebase Connection',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _testResult,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}