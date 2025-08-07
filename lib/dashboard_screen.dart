import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomorrow'), // Or an Instagram-like title/logo
        automaticallyImplyLeading: false, // Removes back button
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Action for likes/notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined), // Using outlined version for a lighter feel
            onPressed: () {
              // Action for messages/DMs
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to your Dashboard!',
          style: TextStyle(fontSize: 20),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_filter_outlined), // Reels icon
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar( // Placeholder for profile picture
              radius: 14,
              // backgroundImage: NetworkImage('YOUR_PROFILE_PIC_URL_HERE'), // If you have a profile pic
              child: Icon(Icons.person, size: 18), // Fallback icon
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: 0, // Default to Home tab
        selectedItemColor: Colors.black, // Active tab color
        unselectedItemColor: Colors.grey, // Inactive tab color
        showUnselectedLabels: false, // Common in Instagram, hides labels for inactive tabs
        showSelectedLabels: false, // Optionally hide for selected too, if icons are clear enough
        type: BottomNavigationBarType.fixed, // Ensures all items are visible and have consistent sizing
        onTap: (index) {
          // Handle bottom navigation tap, e.g., switch pages
        },
      ),
    );
  }
}
