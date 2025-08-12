import 'package:flutter/material.dart';
import 'package:tomorrow/home_feed_screen.dart';
import 'package:tomorrow/search_screen.dart';
import 'package:tomorrow/add_post_screen.dart';
import 'package:tomorrow/reels_screen.dart';
import 'package:tomorrow/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeFeedScreen(),
    SearchScreen(),
    AddPostScreen(),
    ReelsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomorrow'), // Or your app's name
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Action for likes/notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined), // Using outlined for a more modern feel
            onPressed: () {
              // Action for messages/DMs
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
            icon: Icon(Icons.add_box_outlined), // Outlined version for 'add'
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_filter_outlined), // Icon for reels
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Outlined icon for profile
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, // Instagram's selected item is usually black
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // To show all labels
        showSelectedLabels: false, // Hides labels for selected items (like Instagram)
        showUnselectedLabels: false, // Hides labels for unselected items (like Instagram)
      ),
    );
  }
}