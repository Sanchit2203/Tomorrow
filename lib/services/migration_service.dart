import 'package:cloud_firestore/cloud_firestore.dart';

class MigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migrate posts with string timestamps to Firestore Timestamps
  /// This should be run once to update existing data
  Future<void> migratePostTimestamps() async {
    try {
      print('Starting post timestamp migration...');
      
      // Get all posts
      QuerySnapshot snapshot = await _firestore.collection('posts').get();
      
      int migrated = 0;
      int total = snapshot.docs.length;
      
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          bool needsUpdate = false;
          Map<String, dynamic> updates = {};
          
          // Check createdAt
          if (data['createdAt'] is String) {
            DateTime createdAt = DateTime.parse(data['createdAt']);
            updates['createdAt'] = Timestamp.fromDate(createdAt);
            needsUpdate = true;
          }
          
          // Check updatedAt
          if (data['updatedAt'] is String) {
            DateTime updatedAt = DateTime.parse(data['updatedAt']);
            updates['updatedAt'] = Timestamp.fromDate(updatedAt);
            needsUpdate = true;
          }
          
          // Check scheduledAt
          if (data['scheduledAt'] != null && data['scheduledAt'] is String) {
            DateTime scheduledAt = DateTime.parse(data['scheduledAt']);
            updates['scheduledAt'] = Timestamp.fromDate(scheduledAt);
            needsUpdate = true;
          }
          
          // Update the document if needed
          if (needsUpdate) {
            await doc.reference.update(updates);
            migrated++;
            print('Migrated post ${doc.id} ($migrated/$total)');
          }
        } catch (e) {
          print('Error migrating post ${doc.id}: $e');
        }
      }
      
      print('Migration completed. Migrated $migrated out of $total posts.');
    } catch (e) {
      print('Error during migration: $e');
      throw Exception('Failed to migrate post timestamps: $e');
    }
  }

  /// Check if migration is needed by sampling a few posts
  Future<bool> isMigrationNeeded() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .limit(10)
          .get();
      
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // If we find any string timestamps, migration is needed
        if (data['createdAt'] is String || 
            data['updatedAt'] is String || 
            (data['scheduledAt'] != null && data['scheduledAt'] is String)) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error checking migration status: $e');
      return false;
    }
  }
}