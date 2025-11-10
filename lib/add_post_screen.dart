import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:tomorrow/services/media_service.dart';
import 'package:tomorrow/models/post_model.dart';
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
  String? _currentScheduledPostId; // Track scheduled post ID for deletion
  
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

  // Static gradients for better performance
  static const List<List<Color>> _gradients = [
    [Color(0xFF6C5CE7), Color(0xFFA8E6CF)],
    [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
    [Color(0xFF45B7D1), Color(0xFF96CEB4)],
    [Color(0xFFFECEA8), Color(0xFFFFC3A0)],
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFf093fb), Color(0xFFf5576c)],
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
                    color: Colors.black,
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
            color: Colors.black,
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
          cacheExtent: 300, // Cache extent for better performance
          itemBuilder: (context, index) => _buildMediaOption(index),
        ),
      ],
    );
  }

  Widget _buildMediaOption(int index) {
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
            colors: _gradients[index % _gradients.length],
          ),
          boxShadow: [
            BoxShadow(
              color: _gradients[index % _gradients.length].first.withOpacity(0.4),
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
            color: Colors.black,
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
      barrierDismissible: false, // Prevent accidental dismissal during upload
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
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
                      onPressed: _isLoading ? null : () => _handleDialogClose(),
                      icon: Icon(
                        Icons.close, 
                        color: _isLoading ? Colors.grey.shade400 : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Media Preview - Optimized
                        if (_selectedImages.isNotEmpty) ...[
                          Container(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              cacheExtent: 600, // Cache more items for smoother scrolling
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _selectedImages[index],
                                      fit: BoxFit.cover,
                                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                        if (wasSynchronouslyLoaded) return child;
                                        return AnimatedOpacity(
                                          opacity: frame == null ? 0 : 1,
                                          duration: const Duration(milliseconds: 200),
                                          child: child,
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(Icons.error, color: Colors.red),
                                          ),
                                        );
                                      },
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
                        
                        // Caption Input - Optimized
                        Container(
                          height: 100,
                          child: TextField(
                            controller: _captionController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            enabled: !_isLoading,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Write a caption...',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                              filled: true,
                              fillColor: _isLoading ? Colors.grey.shade100 : Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Location Input - Optimized
                        TextField(
                          controller: _locationController,
                          enabled: !_isLoading,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Add location (optional)',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: Icon(
                              Icons.location_on_outlined, 
                              color: _isLoading ? Colors.grey.shade400 : Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                            ),
                            filled: true,
                            fillColor: _isLoading ? Colors.grey.shade100 : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Privacy Toggle - Optimized
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Public Post',
                                style: TextStyle(
                                  fontSize: 16, 
                                  color: _isLoading ? Colors.grey.shade400 : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Switch(
                                value: _isPublic,
                                onChanged: _isLoading ? null : (value) {
                                  setDialogState(() {
                                    _isPublic = value;
                                  });
                                },
                                activeColor: const Color(0xFF6C5CE7),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Time Capsule Scheduling - Optimized
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isLoading ? Colors.grey.shade200 : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _isLoading ? Colors.grey.shade100 : Colors.grey.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: _isLoading 
                                        ? Colors.grey.shade400
                                        : (_isScheduled ? const Color(0xFF6C5CE7) : Colors.grey),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Time Capsule',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _isLoading 
                                          ? Colors.grey.shade400
                                          : (_isScheduled ? const Color(0xFF6C5CE7) : Colors.black),
                                    ),
                                  ),
                                  const Spacer(),
                                  Switch(
                                    value: _isScheduled,
                                    onChanged: _isLoading ? null : (value) {
                                      setDialogState(() {
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
                                    color: _isLoading ? Colors.grey.shade400 : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: _isLoading ? null : () => _selectScheduleDateTime(),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _isLoading ? Colors.grey.shade300 : Colors.grey.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: _isLoading ? Colors.grey.shade200 : Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: _isLoading ? Colors.grey.shade400 : const Color(0xFF6C5CE7),
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
                                                  ? (_isLoading ? Colors.grey.shade500 : Colors.black)
                                                  : (_isLoading ? Colors.grey.shade400 : Colors.grey[600]),
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: _isLoading ? Colors.grey.shade400 : Colors.grey,
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
                
                // Share Button - Fixed at bottom with loading state
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _createPost(setDialogState),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? Colors.grey.shade300 : const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _isLoading ? 0 : 2,
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _isScheduled ? 'Scheduling...' : 'Sharing...',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
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
      ),
    );
  }

  Future<void> _createPost([StateSetter? setDialogState]) async {
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

    // Update loading state for both dialog and main widget
    if (setDialogState != null) {
      setDialogState(() {
        _isLoading = true;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      if (_isScheduled && _scheduledDateTime != null) {
        // Create scheduled post
        PostModel scheduledPost = await _mediaService.createScheduledPost(
          content: _captionController.text,
          scheduledAt: _scheduledDateTime!,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
          video: _selectedVideo,
          location: _locationController.text,
          isPublic: _isPublic,
        );
        
        // Store the scheduled post ID for potential cancellation
        _currentScheduledPostId = scheduledPost.id;
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
      
      // Reset state for both dialog and main widget
      if (setDialogState != null) {
        setDialogState(() {
          _selectedImages.clear();
          _selectedVideo = null;
          _isLoading = false;
          _isScheduled = false;
          _scheduledDateTime = null;
          _currentScheduledPostId = null; // Clear scheduled post ID on success
        });
      } else {
        setState(() {
          _selectedImages.clear();
          _selectedVideo = null;
          _isLoading = false;
          _isScheduled = false;
          _scheduledDateTime = null;
          _currentScheduledPostId = null; // Clear scheduled post ID on success
        });
      }

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
      // Reset loading state on error
      if (setDialogState != null) {
        setDialogState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
      
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

  void _handleDialogClose() async {
    // If there's a scheduled post created but dialog is being closed without completion,
    // show confirmation and delete the scheduled post automatically
    if (_currentScheduledPostId != null) {
      final bool? shouldCancel = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Cancel Time Capsule?',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Your time capsule has been created but not finalized. Do you want to cancel and delete it?',
              style: TextStyle(color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Keep Editing',
                  style: TextStyle(color: Color(0xFF6C5CE7)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel & Delete'),
              ),
            ],
          );
        },
      );

      if (shouldCancel == true) {
        try {
          await _mediaService.deletePost(_currentScheduledPostId!);
          print('Deleted cancelled scheduled post: $_currentScheduledPostId');
          _currentScheduledPostId = null;
          Navigator.pop(context);
          _showSuccessSnackBar('Time capsule cancelled and deleted');
        } catch (e) {
          print('Error deleting cancelled scheduled post: $e');
          _showErrorSnackBar('Failed to cancel time capsule: $e');
        }
      }
      // If shouldCancel is false or null, don't close the dialog
      return;
    }
    
    // If no scheduled post or regular post, just close the dialog
    Navigator.pop(context);
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