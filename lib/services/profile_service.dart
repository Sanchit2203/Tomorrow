import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tomorrow/services/database_service.dart';
import 'package:tomorrow/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _imagePicker = ImagePicker();

  /// Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      return await _databaseService.getCurrentUser();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? username,
  }) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      Map<String, dynamic> updates = {};
      
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (username != null) {
        // Check if username is available (excluding current user)
        bool isAvailable = await _databaseService.isUsernameAvailable(username);
        UserModel? currentUserData = await _databaseService.getCurrentUser();
        
        if (!isAvailable && currentUserData?.username != username.toLowerCase()) {
          throw Exception('Username is already taken');
        }
        updates['username'] = username.toLowerCase();
      }

      if (updates.isNotEmpty) {
        await _databaseService.updateUser(currentUser.uid, updates);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Pick and upload profile image
  Future<String?> updateProfileImage({ImageSource source = ImageSource.gallery}) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // Upload image
      File imageFile = File(pickedFile.path);
      String downloadUrl = await _databaseService.uploadProfileImage(currentUser.uid, imageFile);
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to update profile image: $e');
    }
  }

  /// Remove profile image
  Future<void> removeProfileImage() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      UserModel? userData = await getCurrentUserProfile();
      if (userData != null && userData.profileImageUrl.isNotEmpty) {
        // Delete image from storage
        await _databaseService.deleteImage(userData.profileImageUrl);
        
        // Update user document
        await _databaseService.updateUser(currentUser.uid, {
          'profileImageUrl': '',
        });
      }
    } catch (e) {
      throw Exception('Failed to remove profile image: $e');
    }
  }

  /// Get user profile by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      // Search for users with this username
      List<UserModel> users = await _databaseService.searchUsers(username);
      
      // Find exact match
      for (UserModel user in users) {
        if (user.username.toLowerCase() == username.toLowerCase()) {
          return user;
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get user by username: $e');
    }
  }

  /// Follow/Unfollow user
  Future<void> toggleFollow(String targetUserUid) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      bool isFollowing = await _databaseService.isFollowing(currentUser.uid, targetUserUid);
      
      if (isFollowing) {
        await _databaseService.unfollowUser(currentUser.uid, targetUserUid);
      } else {
        await _databaseService.followUser(currentUser.uid, targetUserUid);
      }
    } catch (e) {
      throw Exception('Failed to toggle follow: $e');
    }
  }

  /// Check if current user is following target user
  Future<bool> isFollowing(String targetUserUid) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      return await _databaseService.isFollowing(currentUser.uid, targetUserUid);
    } catch (e) {
      throw Exception('Failed to check follow status: $e');
    }
  }

  /// Search users
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      return await _databaseService.searchUsers(query);
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Stream current user profile
  Stream<UserModel?> streamCurrentUserProfile() {
    return _databaseService.streamCurrentUser();
  }

  /// Stream user profile by UID
  Stream<UserModel?> streamUserProfile(String uid) {
    return _databaseService.streamUser(uid);
  }

  /// Validate username
  static bool isValidUsername(String username) {
    if (username.isEmpty || username.length < 3 || username.length > 30) {
      return false;
    }
    
    // Username should contain only letters, numbers, dots, and underscores
    RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9._]+$');
    return usernameRegex.hasMatch(username);
  }

  /// Get username validation message
  static String? getUsernameValidationMessage(String username) {
    if (username.isEmpty) {
      return 'Username cannot be empty';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (username.length > 30) {
      return 'Username must be less than 30 characters';
    }
    if (!isValidUsername(username)) {
      return 'Username can only contain letters, numbers, dots, and underscores';
    }
    return null;
  }
}