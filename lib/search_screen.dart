import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final FocusNode _searchFocusNode = FocusNode();
  
  final List<String> _trendingHashtags = [
    '#nature', '#photography', '#art', '#travel', '#food',
    '#sunset', '#coffee', '#adventure', '#life', '#happy'
  ];
  
  final List<String> _recentSearches = [
    'beautiful sunset', 'coffee art', 'mountain hike', 'city life'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Search Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _searchFocusNode.hasFocus 
                            ? const Color(0xFF6C5CE7) 
                            : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search for posts, people, hashtags...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: _searchFocusNode.hasFocus 
                              ? const Color(0xFF6C5CE7) 
                              : Colors.grey.shade500,
                            size: 24,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: Colors.grey.shade500,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, 
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _performSearch(value);
                          }
                        },
                      ),
                    ),
                    
                    // Filter Chips
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', true),
                          _buildFilterChip('Posts', false),
                          _buildFilterChip('People', false),
                          _buildFilterChip('Hashtags', false),
                          _buildFilterChip('Places', false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _searchController.text.isEmpty
                  ? _buildEmptySearchState()
                  : _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6C5CE7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          HapticFeedback.lightImpact();
          // Handle filter selection
        },
        backgroundColor: Colors.transparent,
        selectedColor: const Color(0xFF6C5CE7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFF6C5CE7),
            width: isSelected ? 0 : 1.5,
          ),
        ),
        elevation: 0,
        pressElevation: 0,
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            const Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...(_recentSearches.map((search) => _buildRecentSearchItem(search))),
            const SizedBox(height: 32),
          ],
          
          // Trending Hashtags
          const Text(
            'Trending Hashtags',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingHashtags.map((hashtag) => _buildHashtagChip(hashtag)).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Discover Section
          const Text(
            'Discover',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDiscoverGrid(),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String search) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.history_rounded,
            color: Colors.grey.shade600,
            size: 20,
          ),
        ),
        title: Text(
          search,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.clear_rounded,
            color: Colors.grey.shade400,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _recentSearches.remove(search);
            });
          },
        ),
        onTap: () {
          _searchController.text = search;
          _performSearch(search);
        },
      ),
    );
  }

  Widget _buildHashtagChip(String hashtag) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _searchController.text = hashtag;
        _performSearch(hashtag);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6C5CE7).withOpacity(0.1),
              const Color(0xFFA8E6CF).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6C5CE7).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          hashtag,
          style: const TextStyle(
            color: Color(0xFF6C5CE7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildDiscoverItem(index),
    );
  }

  Widget _buildDiscoverItem(int index) {
    final gradients = [
      [const Color(0xFF6C5CE7), const Color(0xFFA8E6CF)],
      [const Color(0xFFFF6B6B), const Color(0xFF4ECDC4)],
      [const Color(0xFF45B7D1), const Color(0xFF96CEB4)],
      [const Color(0xFFFECEA8), const Color(0xFFFFC3A0)],
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
    ];
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to discover content
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradients[index % gradients.length],
          ),
          boxShadow: [
            BoxShadow(
              color: gradients[index % gradients.length].first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getDiscoverIcon(index),
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDiscoverTitle(index),
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
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(index + 1) * 1200}+',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 10,
      itemBuilder: (context, index) => _buildSearchResultItem(index),
    );
  }

  Widget _buildSearchResultItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF1E1E2E) 
          : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7),
                  const Color(0xFFA8E6CF),
                ],
              ),
            ),
            child: const Icon(
              Icons.image_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Result ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This is a search result description that matches your query.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey.shade400,
            size: 16,
          ),
        ],
      ),
    );
  }

  IconData _getDiscoverIcon(int index) {
    final icons = [
      Icons.local_fire_department_rounded,
      Icons.photo_camera_rounded,
      Icons.music_note_rounded,
      Icons.restaurant_rounded,
      Icons.travel_explore_rounded,
      Icons.palette_rounded,
    ];
    return icons[index % icons.length];
  }

  String _getDiscoverTitle(int index) {
    final titles = [
      'Trending\nNow',
      'Amazing\nPhotos',
      'Music\n& Audio',
      'Food\n& Drink',
      'Travel\n& Places',
      'Art &\nDesign',
    ];
    return titles[index % titles.length];
  }

  void _performSearch(String query) {
    HapticFeedback.mediumImpact();
    // Add to recent searches if not already there
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
    
    // Perform actual search logic here
    print('Searching for: $query');
  }
}