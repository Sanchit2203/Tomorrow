import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tomorrow/models/post_model.dart';
import 'package:tomorrow/models/user_model.dart';
import 'package:tomorrow/services/database_service.dart';

class MediaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _imagePicker = ImagePicker();

  // Collections
  static const String postsCollection = 'posts';

  // Post Methods

  /// Create a new post with optional media
  Future<PostModel> createPost({
    required String content,
    List<File>? images,
    File? video,
    String location = '',
    bool isPublic = true,
  }) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Get user data
      UserModel? userData = await _databaseService.getCurrentUser();
      if (userData == null) {
        throw Exception('User data not found');
      }

      print('Creating post for user: ${userData.username}');

      // Upload images if provided
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        print('Uploading ${images.length} images...');
        for (int i = 0; i < images.length; i++) {
          String imageUrl = await _uploadPostImage(currentUser.uid, images[i], 'image_$i');
          imageUrls.add(imageUrl);
        }
        print('Images uploaded successfully');
      }

      // Upload video if provided
      String? videoUrl;
      if (video != null) {
        print('Uploading video...');
        videoUrl = await _uploadPostVideo(currentUser.uid, video);
        print('Video uploaded successfully');
      }

      // Extract hashtags and mentions from content
      List<String> hashtags = _extractHashtags(content);
      List<String> mentions = _extractMentions(content);

      // Create post document
      DocumentReference postRef = _firestore.collection(postsCollection).doc();
      
      PostModel post = PostModel(
        id: postRef.id,
        authorId: currentUser.uid,
        authorUsername: userData.username,
        authorDisplayName: userData.displayName,
        authorProfileImage: userData.profileImageUrl,
        content: content,
        imageUrls: imageUrls,
        videoUrl: videoUrl,
        hashtags: hashtags,
        mentions: mentions,
        location: location,
        isPublic: isPublic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await postRef.set(post.toMap());
      print('Post created successfully');

      // Update user's post count
      await _databaseService.updateUser(currentUser.uid, {
        'postCount': FieldValue.increment(1),
      });

      return post;
    } catch (e) {
      print('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  /// Upload multiple images from gallery or camera
  Future<List<File>> pickImages({
    ImageSource source = ImageSource.gallery,
    int maxImages = 10,
  }) async {
    try {
      List<File> selectedImages = [];

      if (source == ImageSource.gallery) {
        // Pick multiple images from gallery
        List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (pickedFiles.isNotEmpty) {
          // Limit to maxImages
          List<XFile> limitedFiles = pickedFiles.take(maxImages).toList();
          selectedImages = limitedFiles.map((file) => File(file.path)).toList();
        }
      } else {
        // Take photo with camera
        XFile? pickedFile = await _imagePicker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          selectedImages.add(File(pickedFile.path));
        }
      }

      return selectedImages;
    } catch (e) {
      throw Exception('Failed to pick images: $e');
    }
  }

  /// Pick video from gallery or camera
  Future<File?> pickVideo({ImageSource source = ImageSource.gallery}) async {
    try {
      XFile? pickedFile = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5), // 5 minute limit
      );

      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      throw Exception('Failed to pick video: $e');
    }
  }

  /// Get user's posts
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(postsCollection)
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get user posts: $e');
    }
  }

  /// Get feed posts
  Future<List<PostModel>> getFeedPosts({int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(postsCollection)
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get feed posts: $e');
    }
  }

  // Private helper methods

  Future<String> _uploadPostImage(String userId, File imageFile, String fileName) async {
    try {
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName.jpg';
      Reference ref = _storage.ref().child('users/$userId/posts/$uniqueFileName');
      
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload post image: $e');
    }
  }

  Future<String> _uploadPostVideo(String userId, File videoFile) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_video.mp4';
      Reference ref = _storage.ref().child('users/$userId/posts/$fileName');
      
      UploadTask uploadTask = ref.putFile(videoFile);
      TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload post video: $e');
    }
  }

  List<String> _extractHashtags(String text) {
    RegExp hashtagRegex = RegExp(r'#\w+');
    Iterable<Match> matches = hashtagRegex.allMatches(text);
    return matches.map((match) => match.group(0)!).toSet().toList();
  }

  List<String> _extractMentions(String text) {
    RegExp mentionRegex = RegExp(r'@\w+');
    Iterable<Match> matches = mentionRegex.allMatches(text);
    return matches.map((match) => match.group(0)!).toSet().toList();
  }

  // Stream methods

  /// Stream user's posts
  Stream<List<PostModel>> streamUserPosts(String userId) {
    return _firestore
        .collection(postsCollection)
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList());
  }

  /// Stream feed posts
  Stream<List<PostModel>> streamFeedPosts({int limit = 20}) {
    return _firestore
        .collection(postsCollection)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList());
  }
}