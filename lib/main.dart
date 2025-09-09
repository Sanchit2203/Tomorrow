import 'package:flutter/material.dart';
import 'package:tomorrow/signup_page.dart'; // Added import for signup_page.dart
import 'package:tomorrow/dashboard_screen.dart'; // Import the new dashboard screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Instagram Login', // You might want to change this to 'Tomorrow'
      theme: ThemeData.light().copyWith( // Basic light theme
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // You can further customize the light theme here if needed
        // For example, to match the previous blue primary swatch:
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData.dark().copyWith( // Basic dark theme
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // You can further customize the dark theme here if needed
      ),
      themeMode: ThemeMode.system, // This tells Flutter to use the system theme
      home: const LoginPage(),
      routes: {
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardScreen(), // Add dashboard route
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Process login
      String username = _usernameController.text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logging in with $username... (not implemented)')),
      );
      // Implement your actual login logic here

      // Navigate to DashboardScreen after login
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Instagram-like Logo (You can use an Image.asset here)
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.green,
                      Colors.blue,
                      Colors.indigo,
                      Colors.purple,
                    ],
                    tileMode: TileMode.mirror,
                  ).createShader(bounds),
                  child: const Text(
                    'Tomorrow', // Replace with your app's name or logo
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold, // Adjust if Satisfy font looks better without it
                      fontFamily: 'Satisfy', 
                      color: Colors.white, // Important: Text color needs to be non-transparent (e.g. white) for ShaderMask
                    ),
                  ),
                ),
                const SizedBox(height: 48.0),

                // Username/Email TextField
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Phone number, username, or email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username or email';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),

                // Password TextField
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  obscureText: true,
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
                const SizedBox(height: 24.0),

                // Login Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    textStyle: const TextStyle(fontSize: 16.0, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _login,
                  child: const Text('Log In', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16.0),

                // OR Separator
                Row(
                  children: <Widget>[
                    Expanded(child: Divider(color: Colors.grey[400])),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Login with Google (Example)
                TextButton.icon(
                  icon: const Icon(Icons.email, color: Colors.redAccent), // Using email icon for Google
                  label: const Text(
                    'Log in with Google',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    // Implement Google login
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google login not implemented')),
                    );
                  },
                ),
                const SizedBox(height: 16.0),


                // Forgot Password?
                TextButton(
                  onPressed: () {
                    // Navigate to forgot password screen
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Forgot password not implemented')),
                    );
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),

                // Separator before Sign Up
                const SizedBox(height: 20), // Adjust spacing as needed
                Divider(color: Colors.grey[400]),
                const SizedBox(height: 10), // Adjust spacing as needed


                // Don't have an account? Sign up.
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signup'); // Navigate to signup page
                      },
                      child: const Text(
                        'Sign up.',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
