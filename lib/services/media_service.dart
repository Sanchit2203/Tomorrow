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
        isScheduled: false,
        postStatus: 'published', // Set status as published for regular posts
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

  /// Create a scheduled time capsule post
  Future<PostModel> createScheduledPost({
    required String content,
    required DateTime scheduledAt,
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

      // Validate scheduled time is in the future
      if (scheduledAt.isBefore(DateTime.now())) {
        throw Exception('Scheduled time must be in the future');
      }

      // Get user data
      UserModel? userData = await _databaseService.getCurrentUser();
      if (userData == null) {
        throw Exception('User data not found');
      }

      print('Creating scheduled post for user: ${userData.username}');
      print('Scheduled for: ${scheduledAt.toString()}');

      // Upload images if provided
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        print('Uploading ${images.length} images...');
        for (int i = 0; i < images.length; i++) {
          String imageUrl = await _uploadPostImage(currentUser.uid, images[i], 'scheduled_image_$i');
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

      // Create scheduled post document
      DocumentReference postRef = _firestore.collection(postsCollection).doc();
      
      PostModel scheduledPost = PostModel(
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
        isScheduled: true,
        scheduledAt: scheduledAt,
        postStatus: 'scheduled',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await postRef.set(scheduledPost.toMap());
      print('Scheduled post created successfully');

      return scheduledPost;
    } catch (e) {
      print('Error creating scheduled post: $e');
      throw Exception('Failed to create scheduled post: $e');
    }
  }

  /// Cancel a scheduled post
  Future<void> cancelScheduledPost(String postId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      print('Cancelling scheduled post: $postId');

      // Get post data first to verify ownership
      DocumentSnapshot postDoc = await _firestore.collection(postsCollection).doc(postId).get();
      
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      PostModel post = PostModel.fromDocument(postDoc);

      // Verify user owns the post
      if (post.authorId != currentUser.uid) {
        throw Exception('You can only cancel your own posts');
      }

      // Verify it's a scheduled post
      if (!post.isScheduled || post.postStatus != 'scheduled') {
        throw Exception('Post is not scheduled or already published');
      }

      // Update post status to cancelled
      await _firestore.collection(postsCollection).doc(postId).update({
        'postStatus': 'cancelled',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('Scheduled post cancelled successfully');
    } catch (e) {
      print('Error cancelling scheduled post: $e');
      throw Exception('Failed to cancel scheduled post: $e');
    }
  }

  /// Publish a scheduled post (called when scheduled time arrives)
  Future<void> publishScheduledPost(String postId) async {
    try {
      print('Publishing scheduled post: $postId');

      DocumentSnapshot postDoc = await _firestore.collection(postsCollection).doc(postId).get();
      
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      PostModel post = PostModel.fromDocument(postDoc);

      // Verify it's a scheduled post that should be published
      if (!post.isScheduled || post.postStatus != 'scheduled') {
        throw Exception('Post is not scheduled or already published');
      }

      if (post.scheduledAt == null || post.scheduledAt!.isAfter(DateTime.now())) {
        throw Exception('Post is not ready to be published yet');
      }

      // Update post status to published and increment user's post count
      await _firestore.collection(postsCollection).doc(postId).update({
        'postStatus': 'published',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update user's post count
      await _databaseService.updateUser(post.authorId, {
        'postCount': FieldValue.increment(1),
      });

      print('Scheduled post published successfully');
    } catch (e) {
      print('Error publishing scheduled post: $e');
      throw Exception('Failed to publish scheduled post: $e');
    }
  }

  /// Stream scheduled posts for a user
  Stream<List<PostModel>> streamUserScheduledPosts(String userId) {
    return _firestore
        .collection(postsCollection)
        .where('authorId', isEqualTo: userId)
        .where('isScheduled', isEqualTo: true)
        .where('postStatus', isEqualTo: 'scheduled')
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList());
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

  /// Stream user's posts (only published posts)
  Stream<List<PostModel>> streamUserPosts(String userId) {
    return _firestore
        .collection(postsCollection)
        .where('authorId', isEqualTo: userId)
        .where('postStatus', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList());
  }

  /// Stream all user's posts including scheduled ones (for profile view)
  Stream<List<PostModel>> streamAllUserPosts(String userId) {
    return _firestore
        .collection(postsCollection)
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final now = DateTime.now();
          List<PostModel> posts = [];
          List<String> postsToAutoPublish = [];
          
          for (var doc in snapshot.docs) {
            try {
              PostModel post = PostModel.fromDocument(doc);
              
              // Check if this is a scheduled post that should be published now
              if (post.postStatus == 'scheduled' && 
                  post.isScheduled && 
                  post.scheduledAt != null &&
                  !post.scheduledAt!.isAfter(now)) {
                
                postsToAutoPublish.add(post.id);
                // Update the post status in memory for immediate display
                post = post.copyWith(postStatus: 'published');
              }
              
              posts.add(post);
            } catch (e) {
              print('Error processing user post: $e');
              continue;
            }
          }
          
          // Auto-publish scheduled posts that are ready (async, non-blocking)
          if (postsToAutoPublish.isNotEmpty) {
            _autoPublishPostsBackground(postsToAutoPublish, userId);
          }
          
          return posts;
        });
  }
  
  /// Auto-publish posts in background
  Future<void> _autoPublishPostsBackground(List<String> postIds, String userId) async {
    try {
      for (String postId in postIds) {
        try {
          await publishScheduledPost(postId);
          print('Auto-published scheduled post: $postId');
        } catch (e) {
          print('Error auto-publishing post $postId: $e');
        }
      }
      // Note: publishScheduledPost already increments the user's post count
    } catch (e) {
      print('Error in background auto-publishing: $e');
    }
  }

  /// Stream feed posts (published posts + scheduled posts that are ready)
  Stream<List<PostModel>> streamFeedPosts({int limit = 20}) {
    print('Starting streamFeedPosts with limit: $limit');
    return _firestore
        .collection(postsCollection)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit * 2) // Get more to filter
        .snapshots()
        .handleError((error) {
          print('Error in streamFeedPosts: $error');
          print('Error type: ${error.runtimeType}');
        })
        .asyncMap((snapshot) async {
          print('Received snapshot with ${snapshot.docs.length} documents');
          final now = DateTime.now();
          List<PostModel> posts = [];
          
          for (var doc in snapshot.docs) {
            try {
              PostModel post = PostModel.fromDocument(doc);
              
              // Include published posts
              if (post.postStatus == 'published') {
                posts.add(post);
              }
              // Auto-publish scheduled posts that are ready (past their scheduled time)
              else if (post.postStatus == 'scheduled' && 
                       post.isScheduled && 
                       post.scheduledAt != null &&
                       !post.scheduledAt!.isAfter(now)) {
                print('Auto-publishing scheduled post: ${post.id}');
                try {
                  // Auto-publish the scheduled post
                  await _autoPublishScheduledPostInFeed(post.id);
                  
                  // Add the post as published to the feed
                  final publishedPost = post.copyWith(
                    postStatus: 'published',
                    isScheduled: false,
                    scheduledAt: null,
                  );
                  posts.add(publishedPost);
                } catch (e) {
                  print('Failed to auto-publish post ${post.id}: $e');
                  // If auto-publish fails, still show the post as scheduled
                  posts.add(post);
                }
              }
            } catch (e) {
              print('Error processing post document: $e');
              continue;
            }
          }
          
          // Sort by creation date and limit results
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          print('Returning ${posts.length} posts');
          return posts.take(limit).toList();
        });
  }

  /// Auto-publish a single scheduled post for feed display
  Future<void> _autoPublishScheduledPostInFeed(String postId) async {
    try {
      print('Auto-publishing scheduled post in feed: $postId');
      
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        return;
      }

      // Update the post document
      await _firestore.collection(postsCollection).doc(postId).update({
        'postStatus': 'published',
        'isScheduled': false,
        'scheduledAt': null,
        'publishedAt': FieldValue.serverTimestamp(),
      });

      // Increment user's post count
      await _firestore.collection('users').doc(user.uid).update({
        'postCount': FieldValue.increment(1),
      });
      
      print('Successfully auto-published post: $postId');
    } catch (e) {
      print('Error auto-publishing post $postId: $e');
      rethrow;
    }
  }

  /// Auto-publish scheduled posts that are ready
  Future<void> autoPublishReadyPosts() async {
    try {
      final readyPosts = await getPostsReadyToPublish();
      
      for (PostModel post in readyPosts) {
        try {
          await publishScheduledPost(post.id);
          print('Auto-published scheduled post: ${post.id}');
        } catch (e) {
          print('Error auto-publishing post ${post.id}: $e');
        }
      }
    } catch (e) {
      print('Error in auto-publish process: $e');
    }
  }

  /// Check for scheduled posts that should be published now
  Future<List<PostModel>> getPostsReadyToPublish() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(postsCollection)
          .where('isScheduled', isEqualTo: true)
          .where('postStatus', isEqualTo: 'scheduled')
          .where('scheduledAt', isLessThanOrEqualTo: now.toIso8601String())
          .get();

      return snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting posts ready to publish: $e');
      return [];
    }
  }

  /// Delete a post and all its associated media
  Future<void> deletePost(String postId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      print('Deleting post: $postId');

      // Get post data first to access media URLs
      DocumentSnapshot postDoc = await _firestore.collection(postsCollection).doc(postId).get();
      
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      PostModel post = PostModel.fromDocument(postDoc);

      // Verify user owns the post
      if (post.authorId != currentUser.uid) {
        throw Exception('You can only delete your own posts');
      }

      // Delete associated images from storage
      if (post.imageUrls.isNotEmpty) {
        for (String imageUrl in post.imageUrls) {
          try {
            await _storage.refFromURL(imageUrl).delete();
          } catch (e) {
            print('Warning: Failed to delete image $imageUrl: $e');
          }
        }
      }

      // Delete associated video from storage
      if (post.videoUrl != null && post.videoUrl!.isNotEmpty) {
        try {
          await _storage.refFromURL(post.videoUrl!).delete();
        } catch (e) {
          print('Warning: Failed to delete video ${post.videoUrl}: $e');
        }
      }

      // Delete post document from Firestore
      await _firestore.collection(postsCollection).doc(postId).delete();

      // Update user's post count
      await _databaseService.updateUser(currentUser.uid, {
        'postCount': FieldValue.increment(-1),
      });

      print('Post deleted successfully');
    } catch (e) {
      print('Error deleting post: $e');
      throw Exception('Failed to delete post: $e');
    }
  }
}