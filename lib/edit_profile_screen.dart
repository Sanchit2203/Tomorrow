import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tomorrow/services/profile_service.dart';
import 'package:tomorrow/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  
  late TextEditingController _displayNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  
  bool _isLoading = false;
  bool _isCheckingUsername = false;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.user.displayName);
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio);
    
    _usernameController.addListener(_checkUsernameAvailability);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_checkUsernameAvailability);
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability() async {
    final username = _usernameController.text.trim();
    
    if (username.isEmpty || username == widget.user.username) {
      if (mounted) {
        setState(() {
          _usernameError = null;
          _isCheckingUsername = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isCheckingUsername = true;
        _usernameError = null;
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted || username != _usernameController.text.trim()) {
      return;
    }

    try {
      final validationMessage = ProfileService.getUsernameValidationMessage(username);
      if (validationMessage != null) {
        if (mounted) {
          setState(() {
            _usernameError = validationMessage;
            _isCheckingUsername = false;
          });
        }
        return;
      }

      final userData = await _profileService.getUserByUsername(username);
      if (mounted) {
        setState(() {
          _usernameError = userData != null ? 'Username is already taken' : null;
          _isCheckingUsername = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _usernameError = 'Error checking username availability';
          _isCheckingUsername = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_usernameError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fix the errors before saving.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await _profileService.updateProfile(
        displayName: _displayNameController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF00C851),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
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
                    'Save',
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _showImageOptions(context),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFFA8E6CF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode ? Colors.black : Colors.white,
                      ),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[100],
                            backgroundImage: widget.user.profileImageUrl.isNotEmpty 
                              ? NetworkImage(widget.user.profileImageUrl) 
                              : null,
                            child: widget.user.profileImageUrl.isEmpty 
                              ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                              : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF6C5CE7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              _buildTextField(
                controller: _displayNameController,
                label: 'Display Name',
                hint: 'Enter your display name',
                isDarkMode: isDarkMode,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Display name cannot be empty';
                  }
                  if (value.trim().length > 50) {
                    return 'Display name must be less than 50 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Choose a unique username',
                prefix: '@',
                isDarkMode: isDarkMode,
                suffix: _isCheckingUsername
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _usernameError == null && _usernameController.text.isNotEmpty && _usernameController.text != widget.user.username
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return ProfileService.getUsernameValidationMessage(value.trim());
                },
                errorText: _usernameError,
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                hint: 'Tell people about yourself',
                maxLines: 4,
                isDarkMode: isDarkMode,
                validator: (value) {
                  if (value != null && value.length > 150) {
                    return 'Bio must be less than 150 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 40),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Profile Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Choose a unique username to help people find you.\n'
                      '• Add a bio to tell people about yourself.\n'
                      '• Upload a profile picture to personalize your account.',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDarkMode,
    String? prefix,
    Widget? suffix,
    String? Function(String?)? validator,
    String? errorText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            boxShadow: [
              if (!isDarkMode)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: isDarkMode ? Colors.grey[600] : Colors.grey[500]),
              prefixText: prefix,
              prefixStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              errorText: errorText,
              errorStyle: const TextStyle(color: Colors.red, height: 0),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageOptions(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera, color: isDarkMode ? Colors.white70 : Colors.black),
              title: Text('Take Photo', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                _updateProfileImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: isDarkMode ? Colors.white70 : Colors.black),
              title: Text('Choose from Gallery', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                _updateProfileImage(ImageSource.gallery);
              },
            ),
            if (widget.user.profileImageUrl.isNotEmpty)
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
            content: Text('Profile image removed successfully!'),
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
}
