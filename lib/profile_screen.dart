import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual user data from authentication service
    const String username = "Loading...";
    const String profileImageUrl = "";
    const int postCount = 0;
    const int followerCount = 0;
    const int followingCount = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(username, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // TODO: Implement navigation drawer or options
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
                      child: profileImageUrl.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          _buildStatColumn("Posts", postCount),
                          _buildStatColumn("Followers", followerCount),
                          _buildStatColumn("Following", followingCount),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // User Bio (Optional)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Loading...", // TODO: Replace with actual name
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome to Tomorrow", // TODO: Replace with actual bio
                  ),
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Implement Edit Profile navigation or functionality
                    },
                    child: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
          // Story Highlights (Optional) - You can add this later
          // const SizedBox(height: 16.0),
          // _buildStoryHighlights(),

          const Divider(),
          // Posts Grid - Empty State
          SizedBox(
            height: 200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start sharing your memories!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column _buildStatColumn(String label, int number) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          number.toString(),
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

// Example for Story Highlights (can be implemented later)
// Widget _buildStoryHighlights() {
//   return SizedBox(
//     height: 100,
//     child: ListView.builder(
//       scrollDirection: Axis.horizontal,
//       itemCount: 5, // Number of story highlights
//       itemBuilder: (context, index) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: Column(
//             children: [
//               CircleAvatar(
//                 radius: 30,
//                 backgroundColor: Colors.grey[200],
//                 // Add image for story highlight
//               ),
//               const SizedBox(height: 4),
//               Text("Highlight ${index+1}", style: const TextStyle(fontSize: 12)),
//             ],
//           ),
//         );
//       },
//     ),
//   );
// }
