import 'package:flutter/material.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10, // Example: 10 posts
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
          elevation: 0, // Instagram has flat cards
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Post Header: User Avatar & Name
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 16,
                      // backgroundImage: NetworkImage('URL_TO_AVATAR'), // Replace with actual avatar
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'user_name_${index + 1}', // Example user name
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // Action for post options
                      },
                    ),
                  ],
                ),
              ),
              // Post Content (e.g., Image)
              Container(
                height: 300, // Example height for post image
                color: Colors.grey[300], // Placeholder for image
                alignment: Alignment.center,
                child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
                // child: Image.network('URL_TO_POST_IMAGE'), // Replace with actual image
              ),
              // Post Actions (Like, Comment, Send)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.favorite_border), // Use Icons.favorite for liked state
                      onPressed: () {
                        // Like action
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: () {
                        // Comment action
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_outlined),
                      onPressed: () {
                        // Send/Share action
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.bookmark_border), // Use Icons.bookmark for saved state
                      onPressed: () {
                        // Save action
                      },
                    ),
                  ],
                ),
              ),
              // Likes Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  '${index * 10 + 5} likes', // Example likes count
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Caption
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                        text: 'user_name_${index + 1} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: 'This is a sample caption for the post. #flutter #instagram'),
                    ],
                  ),
                ),
              ),
              // View all comments
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: Text(
                  'View all ${index * 3 + 1} comments',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              // Post Timestamp
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: Text(
                  '${index + 1} HOURS AGO',
                  style: const TextStyle(color: Colors.grey, fontSize: 10.0),
                ),
              ),
              const SizedBox(height: 8.0), // Spacing between posts
            ],
          ),
        );
      },
    );
  }
}
