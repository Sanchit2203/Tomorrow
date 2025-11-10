import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tomorrow/create_post_screen.dart';
import 'package:tomorrow/services/media_service.dart';
import 'package:tomorrow/models/post_model.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final MediaService _mediaService = MediaService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(seconds: 1));
          // TODO: Implement actual data refresh
        },
        color: const Color(0xFF6C5CE7),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Posts - StreamBuilder for real feed
            StreamBuilder<List<PostModel>>(
              stream: _mediaService.streamFeedPosts(limit: 20),
              builder: (context, snapshot) {
                // Debug prints
                print('StreamBuilder state: ${snapshot.connectionState}');
                print('StreamBuilder hasError: ${snapshot.hasError}');
                if (snapshot.hasError) {
                  print('StreamBuilder error: ${snapshot.error}');
                  print('StreamBuilder error type: ${snapshot.error.runtimeType}');
                }
                print('StreamBuilder hasData: ${snapshot.hasData}');
                if (snapshot.hasData) {
                  print('StreamBuilder data length: ${snapshot.data?.length}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      margin: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Error loading posts: ${snapshot.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  // Empty state
                  return SliverToBoxAdapter(
                    child: Container(
                      height: 400,
                      margin: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Welcome to Tomorrow!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Start following people to see their posts in your feed.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () => _createPost(context),
                              icon: const Icon(Icons.add_photo_alternate),
                              label: const Text('Create Post'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C5CE7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Posts list
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = posts[index];
                      return _buildPostCard(post);
                    },
                    childCount: posts.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createPost(BuildContext context) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreatePostScreen(),
        ),
      );
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully! 🎉'),
            backgroundColor: Color(0xFF00C851),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildPostCard(PostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: post.authorProfileImage.isNotEmpty
                      ? NetworkImage(post.authorProfileImage)
                      : null,
                  child: post.authorProfileImage.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorDisplayName.isNotEmpty
                            ? post.authorDisplayName
                            : post.authorUsername,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '@${post.authorUsername}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showPostOptions(post),
                  icon: const Icon(Icons.more_vert),
                  iconSize: 20,
                ),
              ],
            ),
          ),

          // Post content
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black),
              ),
            ),

          // Post media
          if (post.imageUrls.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 300,
              child: PageView.builder(
                itemCount: post.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        post.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF6C5CE7)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

          if (post.videoUrl != null)
            Container(
              margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),

          // Post actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _likePost(post),
                        icon: Icon(
                          Icons.favorite,
                          color: post.likes.contains('current_user_id') // TODO: Replace with actual user ID
                              ? Colors.red
                              : Colors.grey,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      Text('${post.likeCount}', style: const TextStyle(fontSize: 14, color: Colors.black)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _commentOnPost(post),
                        icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      Text('${post.commentCount}', style: const TextStyle(fontSize: 14, color: Colors.black)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _sharePost(post),
                        icon: const Icon(Icons.share_outlined, color: Colors.grey),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      Text('${post.shareCount}', style: const TextStyle(fontSize: 14, color: Colors.black)),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _savePost(post),
                  icon: const Icon(Icons.bookmark_border, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Hashtags
          if (post.hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: post.hashtags.map((tag) => GestureDetector(
                  onTap: () => _searchHashtag(tag),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showPostOptions(PostModel post) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && currentUser.uid == post.authorId;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editPost(post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeletePost(post);
                },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _sharePost(post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy link'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement copy link
              },
            ),
            if (!isOwner)
              ListTile(
                leading: const Icon(Icons.report, color: Colors.orange),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement report
                },
              ),
          ],
        ),
      ),
    );
  }

  void _likePost(PostModel post) {
    // TODO: Implement like functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Like functionality coming soon!')),
    );
  }

  void _commentOnPost(PostModel post) {
    // TODO: Implement comment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment functionality coming soon!')),
    );
  }

  void _sharePost(PostModel post) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _savePost(PostModel post) {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Save functionality coming soon!')),
    );
  }

  void _searchHashtag(String hashtag) {
    // TODO: Implement hashtag search
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for $hashtag...')),
    );
  }

  void _editPost(PostModel post) {
    // TODO: Implement post editing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon!')),
    );
  }

  void _confirmDeletePost(PostModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete Post',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(post);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(PostModel post) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
              SizedBox(width: 12),
              Text('Deleting post...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      await MediaService().deletePost(post.id);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Post deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to delete post: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}