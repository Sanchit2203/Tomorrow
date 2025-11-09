import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tomorrow/services/profile_service.dart';
import 'package:tomorrow/services/auth_service.dart';
import 'package:tomorrow/services/media_service.dart';
import 'package:tomorrow/models/user_model.dart';
import 'package:tomorrow/models/post_model.dart';
import 'package:tomorrow/edit_profile_screen.dart';
import 'package:tomorrow/test_firebase_screen.dart';
import 'package:tomorrow/create_post_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final MediaService _mediaService = MediaService();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _profileService.streamCurrentUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              backgroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final user = snapshot.data;
        final String username = user?.username ?? "Loading...";
        final String displayName = user?.displayName ?? "";
        final String bio = user?.bio ?? "";
        final String profileImageUrl = user?.profileImageUrl ?? "";
        final int postCount = user?.postCount ?? 0;
        final int followerCount = user?.followerCount ?? 0;
        final int followingCount = user?.followingCount ?? 0;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              username == "Loading..." ? "Profile" : "@$username", 
              style: const TextStyle(
                color: Colors.black, 
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            centerTitle: false,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.add_box_outlined, color: Colors.black),
                tooltip: 'Create Content',
                onSelected: (value) {
                  switch (value) {
                    case 'post':
                      _createPost('photo');
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'post',
                    child: Row(
                      children: [
                        Icon(Icons.add_photo_alternate, color: Color(0xFF6C5CE7)),
                        SizedBox(width: 8),
                        Text('Create Post'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildProfileHeader(
                user: user,
                displayName: displayName,
                bio: bio,
                username: username,
                profileImageUrl: profileImageUrl,
                postCount: postCount,
                followerCount: followerCount,
                followingCount: followingCount,
              ),
            ],
            body: Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPostsGrid(),
                      _buildTaggedGrid(),
                      _buildSavedGrid(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader({
    required UserModel? user,
    required String displayName,
    required String bio,
    required String username,
    required String profileImageUrl,
    required int postCount,
    required int followerCount,
    required int followingCount,
  }) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile info row
            Row(
              children: [
                // Profile picture
                GestureDetector(
                  onTap: () => _showProfileImageOptions(context),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFFA8E6CF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: profileImageUrl.isNotEmpty 
                          ? NetworkImage(profileImageUrl) 
                          : null,
                        child: profileImageUrl.isEmpty 
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Stats
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn("Posts", postCount),
                      _buildStatColumn("Followers", followerCount),
                      _buildStatColumn("Following", followingCount),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Display name
            if (displayName.isNotEmpty) ...[
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Set up your profile",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            // Bio
            if (bio.isNotEmpty) ...[
              Text(
                bio,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Add a bio to tell people about yourself",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Action buttons
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: ElevatedButton.icon(
                    onPressed: () => _editProfile(context, user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text(
                      "Edit Profile", 
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _shareProfile(context),
                      icon: const Icon(Icons.share_outlined, color: Colors.black87),
                      tooltip: 'Share Profile',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _showSettingsMenu(context),
                      icon: const Icon(Icons.more_vert, color: Colors.black87),
                      tooltip: 'More Options',
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

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF6C5CE7),
            indicatorWeight: 2,
            labelColor: const Color(0xFF6C5CE7),
            unselectedLabelColor: Colors.grey[600],
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(
                icon: Icon(Icons.grid_on, size: 24),
                text: 'Posts',
              ),
              Tab(
                icon: Icon(Icons.person_pin_circle_outlined, size: 24),
                text: 'Tagged',
              ),
              Tab(
                icon: Icon(Icons.bookmark_border, size: 24),
                text: 'Saved',
              ),
            ],
          ),
          Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    return StreamBuilder<UserModel?>(
      stream: _profileService.streamCurrentUserProfile(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final userId = userSnapshot.data!.uid;
        
        return StreamBuilder<List<PostModel>>(
          stream: _mediaService.streamUserPosts(userId),
          builder: (context, postsSnapshot) {
            if (postsSnapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: Colors.grey[50],
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                  ),
                ),
              );
            }

            if (postsSnapshot.hasError) {
              return Container(
                color: Colors.grey[50],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading posts: ${postsSnapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final posts = postsSnapshot.data ?? [];
            
            if (posts.isEmpty) {
              // Empty state
              return Container(
                color: Colors.grey[50],
                child: SingleChildScrollView(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 400),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.photo_camera_outlined,
                                size: 60,
                                color: Color(0xFF6C5CE7),
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'Share your first photo',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'When you share photos, they\'ll appear on your profile.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () => _createPost('photo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C5CE7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 4,
                              ),
                              icon: const Icon(Icons.add_photo_alternate, size: 20),
                              label: const Text(
                                'Create your first post',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            // Posts grid
            return Container(
              color: Colors.grey[50],
              child: GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildPostGridItem(post);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostGridItem(PostModel post) {
    return GestureDetector(
      onTap: () => _viewPost(post),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main image
            if (post.imageUrls.isNotEmpty)
              Image.network(
                post.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 40,
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
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                      ),
                    ),
                  );
                },
              )
            else if (post.videoUrl != null)
              Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              )
            else
              Container(
                color: Colors.grey[100],
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      post.content,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),

            // Multi-image indicator
            if (post.imageUrls.length > 1)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.copy_rounded,
                  color: Colors.white,
                  size: 20,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),

            // Video indicator
            if (post.videoUrl != null)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 20,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),

            // Likes count overlay
            if (post.likeCount > 0)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${post.likeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _viewPost(PostModel post) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Post Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Image.network(
                              post.imageUrls.first,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      if (post.imageUrls.isNotEmpty) const SizedBox(height: 12),
                      Text(
                        post.content,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text('${post.likeCount}'),
                          const SizedBox(width: 16),
                          const Icon(Icons.comment, color: Colors.blue, size: 16),
                          const SizedBox(width: 4),
                          Text('${post.commentCount}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaggedGrid() {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(minHeight: 400),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_pin_circle_outlined,
                      size: 50,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Photos of you',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'When people tag you in photos, they\'ll appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedGrid() {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(minHeight: 400),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      size: 50,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Saved posts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Save posts you want to see again. Only you can see what you\'ve saved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int number) {
    return GestureDetector(
      onTap: () => _showStatDetails(context, label, number),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatNumber(number),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Action methods
  void _showSettingsMenu(BuildContext context) {
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
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _openSettings(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Saved'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('QR Code'),
              onTap: () {
                Navigator.pop(context);
                _showQRCode(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Test Firebase'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestFirebaseScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileImageOptions(BuildContext context) {
    HapticFeedback.lightImpact();
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
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _updateProfileImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _updateProfileImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _removeProfileImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfileImage(ImageSource source) async {
    try {
      String? imageUrl = await _profileService.updateProfileImage(source: source);
      if (imageUrl != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: Color(0xFF00C851),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile image: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      await _profileService.removeProfileImage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image removed'),
            backgroundColor: Color(0xFF00C851),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove profile image: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _editProfile(BuildContext context, UserModel? user) {
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileScreen(user: user),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to edit profile. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _shareProfile(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile shared!')),
    );
  }

  void _showStatDetails(BuildContext context, String label, int number) {
    String message;
    if (number == 0) {
      switch (label.toLowerCase()) {
        case 'posts':
          message = 'You haven\'t shared any posts yet. Start sharing to build your profile!';
          break;
        case 'followers':
          message = 'You don\'t have any followers yet. Share great content to attract followers!';
          break;
        case 'following':
          message = 'You\'re not following anyone yet. Discover and follow people you\'re interested in!';
          break;
        default:
          message = 'You have ${_formatNumber(number)} ${label.toLowerCase()}';
      }
    } else {
      message = 'You have ${_formatNumber(number)} ${label.toLowerCase()}';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }



  void _createPost(String type) async {
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

  void _openSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings screen coming soon!')),
    );
  }

  void _showQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code'),
        content: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.qr_code, size: 100, color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _authService.signOut();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Color(0xFF00C851),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to logout: ${e.toString().replaceFirst('Exception: ', '')}'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
