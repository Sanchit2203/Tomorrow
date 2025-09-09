import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final Set<int> _likedPosts = {};
  final Set<int> _savedPosts = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(seconds: 1));
        },
        color: const Color(0xFF6C5CE7),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Stories Section
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return _buildStoryItem(index, isDark);
                  },
                ),
              ),
            ),
            
            // Posts
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPostCard(index, isDark),
                childCount: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(int index, bool isDark) {
    final isFirst = index == 0;
    
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isFirst
                ? LinearGradient(
                    colors: [
                      const Color(0xFF6C5CE7),
                      const Color(0xFFA8E6CF),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFFFF6B6B),
                      const Color(0xFF4ECDC4),
                      const Color(0xFF45B7D1),
                    ],
                  ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                    ),
                    child: isFirst
                      ? Icon(
                          Icons.add_rounded,
                          color: const Color(0xFF6C5CE7),
                          size: 28,
                        )
                      : Icon(
                          Icons.person_rounded,
                          color: Colors.grey.shade600,
                          size: 32,
                        ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFirst ? 'Your Story' : 'user_${index}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(int index, bool isDark) {
    final isLiked = _likedPosts.contains(index);
    final isSaved = _savedPosts.contains(index);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C5CE7),
                        const Color(0xFFA8E6CF),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'creator_${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${index + 1}h ago • San Francisco',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showPostOptions(context, index);
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          
          // Post Content
          Container(
            height: 300,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6C5CE7).withOpacity(0.3),
                  Color(0xFFA8E6CF).withOpacity(0.3),
                  Color(0xFFFFD3A5).withOpacity(0.3),
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_rounded,
                        size: 60,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Beautiful Memory',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Post Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildActionButton(
                  icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isLiked ? Colors.red : null,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      if (isLiked) {
                        _likedPosts.remove(index);
                      } else {
                        _likedPosts.add(index);
                      }
                    });
                  },
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showCommentsBottomSheet(context, index);
                  },
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.send_rounded,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showShareBottomSheet(context);
                  },
                ),
                const Spacer(),
                _buildActionButton(
                  icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isSaved ? const Color(0xFF6C5CE7) : null,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (isSaved) {
                        _savedPosts.remove(index);
                      } else {
                        _savedPosts.add(index);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Likes Count
          if (isLiked || index % 3 == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${(index * 12 + 47)} likes',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          
          // Caption
          Padding(
            padding: const EdgeInsets.all(16),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: 'creator_${index + 1} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: _getCaptionText(index),
                  ),
                  TextSpan(
                    text: ' ${_getHashtags(index)}',
                    style: TextStyle(
                      color: const Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Comments Preview
          if (index % 2 == 0)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: GestureDetector(
                onTap: () => _showCommentsBottomSheet(context, index),
                child: Text(
                  'View all ${index * 3 + 12} comments',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: color ?? Colors.grey.shade700,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  String _getCaptionText(int index) {
    final captions = [
      'Living my best life! ✨',
      'Another beautiful day in paradise 🌅',
      'Grateful for moments like these 🙏',
      'Adventures await! 🚀',
      'Making memories that last forever 📸',
      'Sunset vibes hitting different 🌄',
      'Coffee and good company ☕',
      'Weekend mood activated! 🎉',
      'Chasing dreams and catching flights ✈️',
      'Simple moments, pure joy 💫',
    ];
    return captions[index % captions.length];
  }

  String _getHashtags(int index) {
    final hashtags = [
      '#blessed #life #happy',
      '#sunset #nature #peaceful',
      '#grateful #mindfulness #zen',
      '#adventure #explore #wanderlust',
      '#memories #photography #art',
      '#golden hour #magic #beautiful',
      '#coffee #morningvibes #lifestyle',
      '#weekend #fun #goodtimes',
      '#travel #dreams #motivation',
      '#joy #simple #moments',
    ];
    return hashtags[index % hashtags.length];
  }

  void _showPostOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(Icons.share_rounded, 'Share Post', () {}),
            _buildOptionTile(Icons.link_rounded, 'Copy Link', () {}),
            _buildOptionTile(Icons.report_rounded, 'Report', () {}),
            _buildOptionTile(Icons.block_rounded, 'Block User', () {}),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${index * 3 + 12}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 8,
                  itemBuilder: (context, commentIndex) => _buildCommentItem(commentIndex),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Share to...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(Icons.message_rounded, 'Messages', const Color(0xFF25D366)),
                _buildShareOption(Icons.email_rounded, 'Email', const Color(0xFF1877F2)),
                _buildShareOption(Icons.link_rounded, 'Copy Link', const Color(0xFF6C5CE7)),
                _buildShareOption(Icons.more_horiz_rounded, 'More', Colors.grey.shade600),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6C5CE7)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildCommentItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
            ),
            child: Icon(
              Icons.person_rounded,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: 'user_${index + 1} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: 'This is amazing! 🔥'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${index + 1}h',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.favorite_border_rounded,
            size: 16,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
