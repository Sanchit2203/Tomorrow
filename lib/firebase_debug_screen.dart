import 'package:flutter/material.dart';
import 'package:tomorrow/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDebugScreen extends StatefulWidget {
  const FirebaseDebugScreen({super.key});

  @override
  State<FirebaseDebugScreen> createState() => _FirebaseDebugScreenState();
}

class _FirebaseDebugScreenState extends State<FirebaseDebugScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, bool> _servicesStatus = {};
  Map<String, String> _configInfo = {};
  bool _connectionTest = false;
  bool _isLoading = false;
  String _testResults = '';

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Running diagnostics...\n';
    });

    try {
      // Check services status
      _servicesStatus = await _firebaseService.checkServicesStatus();
      
      // Get config info
      _configInfo = _firebaseService.getConfigInfo();
      
      // Test connection
      _connectionTest = await _firebaseService.testConnection();
      
      // Additional tests
      await _runAdditionalTests();
      
    } catch (e) {
      setState(() {
        _testResults += 'Error during diagnostics: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runAdditionalTests() async {
    setState(() {
      _testResults += '\n=== Additional Tests ===\n';
    });

    // Test Firebase Auth
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      setState(() {
        _testResults += 'Auth Status: ${currentUser != null ? 'Signed In' : 'Not Signed In'}\n';
        if (currentUser != null) {
          _testResults += 'User ID: ${currentUser.uid}\n';
          _testResults += 'Email: ${currentUser.email ?? 'N/A'}\n';
        }
      });
    } catch (e) {
      setState(() {
        _testResults += 'Auth Test Error: $e\n';
      });
    }

    // Test Firestore
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot testQuery = await firestore.collection('test').limit(1).get();
      setState(() {
        _testResults += 'Firestore Test: Success (${testQuery.docs.length} docs)\n';
      });
    } catch (e) {
      setState(() {
        _testResults += 'Firestore Test Error: $e\n';
      });
    }

    // Test creating a document
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('debug_test').doc('test').set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': 'Firebase debug test'
      });
      setState(() {
        _testResults += 'Firestore Write Test: Success\n';
      });
    } catch (e) {
      setState(() {
        _testResults += 'Firestore Write Test Error: $e\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Debug'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDiagnostics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Firebase Services Status
                  _buildStatusCard(
                    'Firebase Services Status',
                    Icons.cloud,
                    Colors.blue,
                    _buildServicesStatus(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Configuration Info
                  _buildStatusCard(
                    'Configuration',
                    Icons.settings,
                    Colors.green,
                    _buildConfigInfo(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Connection Test
                  _buildStatusCard(
                    'Connection Test',
                    Icons.network_check,
                    _connectionTest ? Colors.green : Colors.red,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _connectionTest ? Icons.check_circle : Icons.error,
                              color: _connectionTest ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _connectionTest ? 'Connected' : 'Connection Failed',
                              style: TextStyle(
                                color: _connectionTest ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Test Results
                  _buildStatusCard(
                    'Test Results',
                    Icons.bug_report,
                    Colors.orange,
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _testResults.isEmpty ? 'No test results yet' : _testResults,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _runDiagnostics,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard(String title, IconData icon, Color color, Widget content) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildServicesStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusItem('Firebase Core', _servicesStatus['core'] ?? false),
        _buildStatusItem('Firebase Auth', _servicesStatus['auth'] ?? false),
        _buildStatusItem('Cloud Firestore', _servicesStatus['firestore'] ?? false),
        _buildStatusItem('Firebase Storage', _servicesStatus['storage'] ?? false),
      ],
    );
  }

  Widget _buildStatusItem(String service, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            service,
            style: TextStyle(
              color: status ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _configInfo.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.key}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(entry.value),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}