import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:tomorrow/services/media_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddPostScreen extends StatefulWidget {
  final VoidCallback? onPostCreated;
  const AddPostScreen({super.key, this.onPostCreated});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> with TickerProviderStateMixin {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  // Post creation variables
  final MediaService _mediaService = MediaService();
  List<File> _selectedImages = [];
  File? _selectedVideo;
  bool _isLoading = false;
  bool _isPublic = true;
  
  // Scheduling variables
  bool _isScheduled = false;
  DateTime? _scheduledDateTime;
  
  final List<String> _mediaOptions = [
    'Camera', 'Gallery', 'Video', 'Reel', 'Live'
  ];
  
  final List<IconData> _mediaIcons = [
    Icons.camera_alt_rounded,
    Icons.photo_library_rounded,
    Icons.videocam_rounded,
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
      case 3: // Reel
        _showCreateReelDialog();
        break;
      case 4: // Live
        _showGoLiveDialog();
        break;
    }
  }

  void _openCamera() async {
    try {
      // Request camera permission
      PermissionStatus cameraPermission = await Permission.camera.request();
      
      if (cameraPermission != PermissionStatus.granted) {
        _showErrorSnackBar('Camera permission is required to take photos');
        return;
      }

      List<File> images = await _mediaService.pickImages(
        source: ImageSource.camera,
        maxImages: 1,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
          _selectedVideo = null; // Clear video if image is selected
        });
        _showPostCreationDialog();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  void _openGallery() async {
    try {
      List<File> images = await _mediaService.pickImages(
        source: ImageSource.gallery,
        maxImages: 10,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
          _selectedVideo = null; // Clear video if images are selected
        });
        _showPostCreationDialog();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
    }
  }

  void _openVideoCamera() async {
    try {
      // Request camera permission
      PermissionStatus cameraPermission = await Permission.camera.request();
      
      if (cameraPermission != PermissionStatus.granted) {
        _showErrorSnackBar('Camera permission is required to record videos');
        return;
      }

      File? video = await _mediaService.pickVideo(source: ImageSource.camera);
      if (video != null) {
        setState(() {
          _selectedVideo = video;
          _selectedImages.clear(); // Clear images if video is selected
        });
        _showPostCreationDialog();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to record video: $e');
    }
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showPostCreationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Media Preview
                      if (_selectedImages.isNotEmpty) ...[
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      if (_selectedVideo != null) ...[
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300],
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_circle_filled, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Video Selected', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Caption Input
                      Container(
                        height: 100,
                        child: TextField(
                          controller: _captionController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: 'Write a caption...',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Location Input
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Add location (optional)',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Privacy Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Public Post',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Switch(
                            value: _isPublic,
                            onChanged: (value) {
                              setState(() {
                                _isPublic = value;
                              });
                            },
                            activeColor: const Color(0xFF6C5CE7),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Time Capsule Scheduling
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: _isScheduled ? const Color(0xFF6C5CE7) : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Time Capsule',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _isScheduled ? const Color(0xFF6C5CE7) : Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: _isScheduled,
                                  onChanged: (value) {
                                    setState(() {
                                      _isScheduled = value;
                                      if (!value) {
                                        _scheduledDateTime = null;
                                      }
                                    });
                                  },
                                  activeColor: const Color(0xFF6C5CE7),
                                ),
                              ],
                            ),
                            if (_isScheduled) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Schedule your post to appear in the future',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () => _selectScheduleDateTime(),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF6C5CE7),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _scheduledDateTime != null
                                              ? '${_formatScheduledDate(_scheduledDateTime!)}'
                                              : 'Select date and time',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _scheduledDateTime != null 
                                                ? Colors.black 
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              // Share Button - Fixed at bottom
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isScheduled ? 'Schedule Post' : 'Share Post',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    if (_captionController.text.isEmpty && _selectedImages.isEmpty && _selectedVideo == null) {
      _showErrorSnackBar('Please add content or media to your post');
      return;
    }

    // Validate scheduled post
    if (_isScheduled) {
      if (_scheduledDateTime == null) {
        _showErrorSnackBar('Please select a date and time for your time capsule');
        return;
      }
      
      if (_scheduledDateTime!.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
        _showErrorSnackBar('Scheduled time must be at least 5 minutes in the future');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isScheduled && _scheduledDateTime != null) {
        // Create scheduled post
        await _mediaService.createScheduledPost(
          content: _captionController.text,
          scheduledAt: _scheduledDateTime!,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
          video: _selectedVideo,
          location: _locationController.text,
          isPublic: _isPublic,
        );
      } else {
        // Create regular post
        await _mediaService.createPost(
          content: _captionController.text,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
          video: _selectedVideo,
          location: _locationController.text,
          isPublic: _isPublic,
        );
      }

      // Clear form
      _captionController.clear();
      _locationController.clear();
      setState(() {
        _selectedImages.clear();
        _selectedVideo = null;
        _isLoading = false;
        _isScheduled = false;
        _scheduledDateTime = null;
      });

      // Close dialog and show success
      if (mounted) {
        Navigator.pop(context);
        final message = _isScheduled 
            ? 'Time capsule scheduled successfully! ⏰'
            : 'Post shared successfully! 🎉';
        _showSuccessSnackBar(message);
        
        // Navigate back to home tab if callback is provided
        widget.onPostCreated?.call();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showErrorSnackBar('Failed to create post: $e');
      }
    }
  }

  Future<void> _selectScheduleDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select date for your time capsule',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C5CE7),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _scheduledDateTime ?? now.add(const Duration(hours: 1)),
        ),
        helpText: 'Select time for your time capsule',
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF6C5CE7),
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        final scheduledDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        // Validate the scheduled time is at least 5 minutes in the future
        if (scheduledDateTime.isBefore(now.add(const Duration(minutes: 5)))) {
          _showErrorSnackBar('Scheduled time must be at least 5 minutes in the future');
          return;
        }

        setState(() {
          _scheduledDateTime = scheduledDateTime;
        });
      }
    }
  }

  String _formatScheduledDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    // Format: "Tomorrow at 2:30 PM" or "Dec 25 at 10:00 AM"
    String dateStr;
    if (difference.inDays == 0) {
      dateStr = 'Today';
    } else if (difference.inDays == 1) {
      dateStr = 'Tomorrow';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      dateStr = days[dateTime.weekday - 1];
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dateStr = '${months[dateTime.month - 1]} ${dateTime.day}';
    }

    // Format time
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final timeStr = '$displayHour:${minute.toString().padLeft(2, '0')} $amPm';

    return '$dateStr at $timeStr';
  }
}