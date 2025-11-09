import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tomorrow/signup_page.dart'; // Added import for signup_page.dart
import 'package:tomorrow/dashboard_screen.dart'; // Import the new dashboard screen
import 'package:tomorrow/services/auth_service.dart';
import 'package:tomorrow/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tomorrow - Social Network',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.light,
          surface: Colors.white,
          onSurface: Colors.black,
          primary: const Color(0xFF6C5CE7),
          onPrimary: Colors.white,
          secondary: const Color(0xFFA8E6CF),
          onSecondary: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w300, color: Colors.black),
          displayMedium: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
          displaySmall: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
          headlineLarge: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
          headlineMedium: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
          headlineSmall: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
          titleLarge: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
          titleMedium: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
          titleSmall: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
          bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
          bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
          bodySmall: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w300),
          displayMedium: TextStyle(fontWeight: FontWeight.w400),
          displaySmall: TextStyle(fontWeight: FontWeight.w400),
          headlineLarge: TextStyle(fontWeight: FontWeight.w400),
          headlineMedium: TextStyle(fontWeight: FontWeight.w400),
          headlineSmall: TextStyle(fontWeight: FontWeight.w400),
          titleLarge: TextStyle(fontWeight: FontWeight.w500),
          titleMedium: TextStyle(fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontWeight: FontWeight.w400),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Haptic feedback
      HapticFeedback.mediumImpact();
      
      try {
        // Authenticate with Firebase
        final userCredential = await _authService.signInWithEmailAndPassword(
          email: _usernameController.text.trim(),
          password: _passwordController.text,
        );
        
        if (userCredential != null && userCredential.user != null) {
          setState(() {
            _isLoading = false;
          });
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${userCredential.user!.email}! 🎉'),
                backgroundColor: const Color(0xFF00C851),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            
            // Navigate to DashboardScreen after successful login
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: const Color(0xFFFF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null && userCredential.user != null) {
        setState(() {
          _isLoading = false;
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${userCredential.user!.displayName ?? userCredential.user!.email}! 🎉'),
              backgroundColor: const Color(0xFF00C851),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          
          // Navigate to DashboardScreen after successful login
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFFF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your email address first'),
          backgroundColor: const Color(0xFFFF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(_usernameController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password reset email sent! Check your inbox 📧'),
            backgroundColor: const Color(0xFF00C851),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFFF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [
                  const Color(0xFF1E1E2E),
                  const Color(0xFF2D1B69),
                  const Color(0xFF11092A),
                ]
              : [
                  const Color(0xFF6C5CE7),
                  const Color(0xFFA8E6CF),
                  const Color(0xFFFFD3A5),
                ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.1),
                  
                  // Animated Logo Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF6B6B),
                                    const Color(0xFF4ECDC4),
                                    const Color(0xFF45B7D1),
                                    const Color(0xFF96CEB4),
                                    const Color(0xFFFECEA8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.punch_clock,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.white, Colors.white70],
                              ).createShader(bounds),
                              child: const Text(
                                'Tomorrow',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your future starts here',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Login Form
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isDark ? 0.05 : 0.15),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            _buildModernTextField(
                              controller: _usernameController,
                              hintText: 'Email Address',
                              prefixIcon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email address';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Password Field
                            _buildModernTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline_rounded,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Login Button
                            _buildModernButton(
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Social Login Buttons
                            _buildSocialButton(
                              icon: Icons.g_mobiledata_rounded,
                              text: 'Continue with Google',
                              colors: [const Color(0xFFDB4437), const Color(0xFFEA4335)],
                              onPressed: _isLoading ? () {} : () => _signInWithGoogle(),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildSocialButton(
                              icon: Icons.apple_rounded,
                              text: 'Continue with Apple',
                              colors: [const Color(0xFF000000), const Color(0xFF333333)],
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Apple login coming soon! 🍎'),
                                    backgroundColor: const Color(0xFF000000),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Forgot Password
                            TextButton(
                              onPressed: () => _resetPassword(),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Sign Up Link
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
          suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildModernButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed != null 
          ? const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [Colors.grey.shade400, Colors.grey.shade500],
            ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null 
          ? [
              BoxShadow(
                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ]
          : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
