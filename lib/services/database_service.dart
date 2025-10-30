import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tomorrow/models/user_model.dart';
import 'dart:io';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';

  // User-related methods

  /// Create a new user document in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      print('Creating user document for UID: ${user.uid}');
      print('Collection: $usersCollection');
      print('User data: ${user.toMap()}');
      
      await _firestore.collection(usersCollection).doc(user.uid).set(user.toMap());
      print('Firestore document created successfully');
      
      // Create user storage folder
      print('Creating user storage folder...');
      await _createUserStorageFolder(user.uid);
      print('Storage folder created successfully');
    } catch (e) {
      print('Error creating user: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  /// Get user data by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(usersCollection).doc(uid).get();
      
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Get current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        return await getUser(currentUser.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Update user data
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection(usersCollection).doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(usersCollection)
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();
      
      return query.docs.isEmpty;
    } catch (e) {
      throw Exception('Failed to check username availability: $e');
    }
  }

  /// Generate unique username from email
  Future<String> generateUniqueUsername(String email) async {
    try {
      String baseUsername = email.split('@')[0].toLowerCase();
      String username = baseUsername;
      int counter = 1;

      while (!(await isUsernameAvailable(username))) {
        username = '${baseUsername}_$counter';
        counter++;
      }

      return username;
    } catch (e) {
      throw Exception('Failed to generate username: $e');
    }
  }

  /// Create user from Firebase Auth User
  Future<UserModel> createUserFromAuth(User firebaseUser) async {
    try {
      print('Creating user from auth for UID: ${firebaseUser.uid}');
      print('Email: ${firebaseUser.email}');
      
      // Generate unique username
      print('Generating unique username...');
      String username = await generateUniqueUsername(firebaseUser.email ?? 'user${DateTime.now().millisecondsSinceEpoch}');
      print('Generated username: $username');
      
      UserModel user = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        username: username,
        displayName: firebaseUser.displayName ?? '',
        profileImageUrl: firebaseUser.photoURL ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('Creating user document in Firestore...');
      await createUser(user);
      print('User document created successfully');
      
      return user;
    } catch (e) {
      print('Error in createUserFromAuth: $e');
      throw Exception('Failed to create user from auth: $e');
    }
  }

  // Storage-related methods

  /// Create user storage folder structure
  Future<void> _createUserStorageFolder(String uid) async {
    try {
      // Create placeholder files to establish folder structure
      final profileRef = _storage.ref().child('users/$uid/profile/placeholder.txt');
      final postsRef = _storage.ref().child('users/$uid/posts/placeholder.txt');
      
      await Future.wait([
        profileRef.putString('User folder created'),
        postsRef.putString('Posts folder created'),
      ]);
    } catch (e) {
      // Don't throw error for folder creation failure as it's not critical
      print('Warning: Could not create user storage folder: $e');
    }
  }

  /// Upload profile image
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    try {
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('users/$uid/profile/$fileName');
      
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update user profile image URL in Firestore
      await updateUser(uid, {'profileImageUrl': downloadUrl});
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Upload post image
  Future<String> uploadPostImage(String uid, File imageFile) async {
    try {
      String fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('users/$uid/posts/$fileName');
      
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload post image: $e');
    }
  }

  /// Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Follow/Unfollow methods

  /// Follow a user
  Future<void> followUser(String currentUserUid, String targetUserUid) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      // Add to current user's following list
      DocumentReference currentUserRef = _firestore.collection(usersCollection).doc(currentUserUid);
      batch.update(currentUserRef, {
        'following': FieldValue.arrayUnion([targetUserUid]),
        'followingCount': FieldValue.increment(1),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      // Add to target user's followers list
      DocumentReference targetUserRef = _firestore.collection(usersCollection).doc(targetUserUid);
      batch.update(targetUserRef, {
        'followers': FieldValue.arrayUnion([currentUserUid]),
        'followerCount': FieldValue.increment(1),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser(String currentUserUid, String targetUserUid) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      // Remove from current user's following list
      DocumentReference currentUserRef = _firestore.collection(usersCollection).doc(currentUserUid);
      batch.update(currentUserRef, {
        'following': FieldValue.arrayRemove([targetUserUid]),
        'followingCount': FieldValue.increment(-1),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      // Remove from target user's followers list
      DocumentReference targetUserRef = _firestore.collection(usersCollection).doc(targetUserUid);
      batch.update(targetUserRef, {
        'followers': FieldValue.arrayRemove([currentUserUid]),
        'followerCount': FieldValue.increment(-1),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  /// Check if current user is following target user
  Future<bool> isFollowing(String currentUserUid, String targetUserUid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(usersCollection).doc(currentUserUid).get();
      
      if (doc.exists) {
        UserModel user = UserModel.fromDocument(doc);
        return user.following.contains(targetUserUid);
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check follow status: $e');
    }
  }

  // Search methods

  /// Search users by username
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];
      
      QuerySnapshot snapshot = await _firestore
          .collection(usersCollection)
          .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('username', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
          .limit(20)
          .get();
      
      return snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Stream methods

  /// Stream user data
  Stream<UserModel?> streamUser(String uid) {
    return _firestore
        .collection(usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromDocument(doc) : null);
  }

  /// Stream current user data
  Stream<UserModel?> streamCurrentUser() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return streamUser(currentUser.uid);
    }
    return Stream.value(null);
  }
}