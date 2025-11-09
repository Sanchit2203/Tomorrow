import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tomorrow/services/media_service.dart';
import 'package:tomorrow/models/post_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final MediaService _mediaService = MediaService();
  
  List<File> _selectedImages = [];
  File? _selectedVideo;
  bool _isLoading = false;
  bool _isPublic = true;

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      List<File> images = await _mediaService.pickImages(
        source: ImageSource.gallery,
        maxImages: 10,
      );
      
      setState(() {
        _selectedImages = images;
        _selectedVideo = null; // Clear video if images are selected
      });
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      List<File> images = await _mediaService.pickImages(
        source: ImageSource.camera,
        maxImages: 1,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          _selectedVideo = null; // Clear video if images are selected
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      File? video = await _mediaService.pickVideo(source: ImageSource.gallery);
      
      if (video != null) {
        setState(() {
          _selectedVideo = video;
          _selectedImages.clear(); // Clear images if video is selected
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick video: $e');
    }
  }

  Future<void> _recordVideo() async {
    try {
      File? video = await _mediaService.pickVideo(source: ImageSource.camera);
      
      if (video != null) {
        setState(() {
          _selectedVideo = video;
          _selectedImages.clear(); // Clear images if video is selected
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to record video: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeVideo() {
    setState(() {
      _selectedVideo = null;
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty && _selectedImages.isEmpty && _selectedVideo == null) {
      _showErrorSnackBar('Please add some content or media to your post');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      PostModel post = await _mediaService.createPost(
        content: _contentController.text.trim(),
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
        video: _selectedVideo,
        location: _locationController.text.trim(),
        isPublic: _isPublic,
      );

      if (mounted) {
        Navigator.pop(context, post);
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
        _showErrorSnackBar('Failed to create post: ${e.toString().replaceFirst('Exception: ', '')}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMediaPicker() {
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
            const Text(
              'Add Media to Post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: _buildMediaOption(
                    icon: Icons.photo_library,
                    label: 'Gallery\nPhotos',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImages();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildMediaOption(
                    icon: Icons.camera_alt,
                    label: 'Take\nPhoto',
                    onTap: () {
                      Navigator.pop(context);
                      _takePhoto();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildMediaOption(
                    icon: Icons.video_library,
                    label: 'Gallery\nVideo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickVideo();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildMediaOption(
                    icon: Icons.videocam,
                    label: 'Record\nVideo',
                    onTap: () {
                      Navigator.pop(context);
                      _recordVideo();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6C5CE7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: const Color(0xFF6C5CE7),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPost,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                    ),
                  )
                : const Text(
                    'Share',
                    style: TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Content input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            // Media preview
            if (_selectedImages.isNotEmpty) _buildImagePreview(),
            if (_selectedVideo != null) _buildVideoPreview(),

            const SizedBox(height: 16),

            // Media picker button
            GestureDetector(
              onTap: _showMediaPicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6C5CE7).withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      color: const Color(0xFF6C5CE7),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Add Photos or Videos',
                      style: TextStyle(
                        color: Color(0xFF6C5CE7),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Add location (optional)',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Privacy settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _isPublic ? Icons.public : Icons.lock,
                    color: const Color(0xFF6C5CE7),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Post visibility:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                    activeColor: const Color(0xFF6C5CE7),
                  ),
                  Text(_isPublic ? 'Public' : 'Private'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImages[index],
                    width: 150,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_circle_fill,
                    size: 48,
                    color: Color(0xFF6C5CE7),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Video Selected',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _removeVideo,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}