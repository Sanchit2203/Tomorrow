import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> with TickerProviderStateMixin {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  final List<String> _mediaOptions = [
    'Camera', 'Gallery', 'Video', 'Story', 'Reel', 'Live'
  ];
  
  final List<IconData> _mediaIcons = [
    Icons.camera_alt_rounded,
    Icons.photo_library_rounded,
    Icons.videocam_rounded,
    Icons.auto_stories_rounded,
    Icons.movie_filter_rounded,
    Icons.live_tv_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
              ? [
                  const Color(0xFF1E1E2E),
                  const Color(0xFF2D1B69).withOpacity(0.8),
                  const Color(0xFF11092A),
                ]
              : [
                  const Color(0xFF6C5CE7).withOpacity(0.1),
                  const Color(0xFFA8E6CF).withOpacity(0.1),
                  Colors.white,
                ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Media Selection Grid
                          _buildMediaSelectionGrid(),
                          
                          const SizedBox(height: 32),
                          
                          // Quick Actions
                          _buildQuickActions(),
                          
                          const SizedBox(height: 32),
                          
                          // Recent Media Preview
                          _buildRecentMediaPreview(),
                        ],
                      ),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.add_circle_outline_rounded,
              color: Color(0xFF6C5CE7),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Post',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Share your moments with the world',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSelectionGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Media Type',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: _mediaOptions.length,
          itemBuilder: (context, index) => _buildMediaOption(index),
        ),
      ],
    );
  }

  Widget _buildMediaOption(int index) {
    final gradients = [
      [const Color(0xFF6C5CE7), const Color(0xFFA8E6CF)],
      [const Color(0xFFFF6B6B), const Color(0xFF4ECDC4)],
      [const Color(0xFF45B7D1), const Color(0xFF96CEB4)],
      [const Color(0xFFFECEA8), const Color(0xFFFFC3A0)],
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
    ];
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _handleMediaSelection(index);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradients[index % gradients.length],
          ),
          boxShadow: [
            BoxShadow(
              color: gradients[index % gradients.length].first.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _mediaIcons[index],
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              _mediaOptions[index],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.flash_on_rounded,
                title: 'Stories',
                subtitle: '24h visibility',
                colors: [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)],
                onTap: () => _showCreateStoryDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.movie_filter_rounded,
                title: 'Reels',
                subtitle: 'Short videos',
                colors: [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
                onTap: () => _showCreateReelDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildQuickActionButton(
          icon: Icons.live_tv_rounded,
          title: 'Go Live',
          subtitle: 'Stream to your followers',
          colors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
          onTap: () => _showGoLiveDialog(),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMediaPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Photos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Navigate to gallery
              },
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) => _buildRecentMediaItem(index),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMediaItem(int index) {
    final gradients = [
      [const Color(0xFF6C5CE7), const Color(0xFFA8E6CF)],
      [const Color(0xFFFF6B6B), const Color(0xFF4ECDC4)],
      [const Color(0xFF45B7D1), const Color(0xFF96CEB4)],
      [const Color(0xFFFECEA8), const Color(0xFFFFC3A0)],
    ];
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _selectRecentMedia(index);
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradients[index % gradients.length],
          ),
          boxShadow: [
            BoxShadow(
              color: gradients[index % gradients.length].first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.image_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMediaSelection(int index) {
    switch (index) {
      case 0: // Camera
        _openCamera();
        break;
      case 1: // Gallery
        _openGallery();
        break;
      case 2: // Video
        _openVideoCamera();
        break;
      case 3: // Story
        _showCreateStoryDialog();
        break;
      case 4: // Reel
        _showCreateReelDialog();
        break;
      case 5: // Live
        _showGoLiveDialog();
        break;
    }
  }

  void _openCamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.camera_alt_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('Camera opening soon! 📸'),
          ],
        ),
        backgroundColor: const Color(0xFF6C5CE7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.photo_library_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('Gallery opening soon! 🖼️'),
          ],
        ),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openVideoCamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.videocam_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('Video camera opening soon! 🎥'),
          ],
        ),
        backgroundColor: const Color(0xFF45B7D1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showCreateStoryDialog() {
    _showFeatureDialog('Stories', 'Create 24-hour stories', Icons.flash_on_rounded, const Color(0xFFFF6B6B));
  }

  void _showCreateReelDialog() {
    _showFeatureDialog('Reels', 'Create short videos', Icons.movie_filter_rounded, const Color(0xFF4ECDC4));
  }

  void _showGoLiveDialog() {
    _showFeatureDialog('Go Live', 'Stream to your followers', Icons.live_tv_rounded, const Color(0xFF667eea));
  }

  void _showFeatureDialog(String title, String description, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Maybe Later'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$title feature coming soon! 🚀'),
                            backgroundColor: color,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Get Started'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectRecentMedia(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected recent photo ${index + 1} 📸'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}