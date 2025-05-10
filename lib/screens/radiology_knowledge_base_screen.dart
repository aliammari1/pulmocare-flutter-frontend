import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class RadiologyKnowledgeBaseScreen extends StatefulWidget {
  const RadiologyKnowledgeBaseScreen({super.key});

  @override
  _RadiologyKnowledgeBaseScreenState createState() =>
      _RadiologyKnowledgeBaseScreenState();
}

class _RadiologyKnowledgeBaseScreenState
    extends State<RadiologyKnowledgeBaseScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _recentArticles = [];
  List<Map<String, dynamic>> _bookmarkedArticles = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock data
    final categories = [
      {
        'id': 'cat1',
        'name': 'X-Ray',
        'icon': Icons.broken_image_outlined,
        'color': Colors.blue.value,
        'articles': 42,
      },
      {
        'id': 'cat2',
        'name': 'MRI',
        'icon': Icons.view_in_ar_outlined,
        'color': Colors.purple.value,
        'articles': 38,
      },
      {
        'id': 'cat3',
        'name': 'CT Scan',
        'icon': Icons.panorama_horizontal_outlined,
        'color': Colors.amber.value,
        'articles': 51,
      },
      {
        'id': 'cat4',
        'name': 'Ultrasound',
        'icon': Icons.waves_outlined,
        'color': Colors.teal.value,
        'articles': 29,
      },
      {
        'id': 'cat5',
        'name': 'Nuclear Medicine',
        'icon': Icons.blur_circular_outlined,
        'color': Colors.red.value,
        'articles': 22,
      },
      {
        'id': 'cat6',
        'name': 'Mammography',
        'icon': Icons.circle_outlined,
        'color': Colors.pink.value,
        'articles': 18,
      },
      {
        'id': 'cat7',
        'name': 'PET Scan',
        'icon': Icons.scanner_outlined,
        'color': Colors.green.value,
        'articles': 24,
      },
      {
        'id': 'cat8',
        'name': 'Angiography',
        'icon': Icons.timeline_outlined,
        'color': Colors.orange.value,
        'articles': 16,
      },
    ];

    final recentArticles = [
      {
        'id': 'art1',
        'title': 'New Advances in Brain MRI Techniques',
        'author': 'Dr. Emily Rodriguez',
        'date': '2025-04-15',
        'category': 'MRI',
        'imageUrl': 'https://example.com/brain-mri.jpg',
        'content':
            'Recent advances in MRI technology have revolutionized our ability to visualize and understand brain structure and function. This article explores the latest techniques including functional MRI (fMRI), diffusion tensor imaging (DTI), and magnetic resonance spectroscopy (MRS), and their clinical applications in diagnosing and monitoring neurological disorders.',
        'isBookmarked': true,
      },
      {
        'id': 'art2',
        'title': 'Optimizing Chest X-Ray Interpretation for COVID-19',
        'author': 'Dr. James Wilson',
        'date': '2025-04-10',
        'category': 'X-Ray',
        'imageUrl': 'https://example.com/chest-xray.jpg',
        'content':
            'This comprehensive guide provides radiologists with key patterns and findings in chest X-rays of COVID-19 patients. Learn to identify ground-glass opacities, consolidation patterns, and other radiographic manifestations that might indicate COVID-19 infection, along with strategies to differentiate them from other respiratory conditions.',
        'isBookmarked': false,
      },
      {
        'id': 'art3',
        'title': 'Understanding CT Dose Reduction Strategies',
        'author': 'Dr. Sarah Lee',
        'date': '2025-03-28',
        'category': 'CT Scan',
        'imageUrl': 'https://example.com/ct-scan.jpg',
        'content':
            'With growing concerns about radiation exposure, implementing effective dose reduction strategies in CT imaging has become increasingly important. This article reviews current techniques including automatic tube current modulation, iterative reconstruction algorithms, and protocol optimization to minimize patient radiation exposure while maintaining diagnostic image quality.',
        'isBookmarked': false,
      },
      {
        'id': 'art4',
        'title': 'Elastography in Liver Assessment',
        'author': 'Dr. Michael Patel',
        'date': '2025-03-22',
        'category': 'Ultrasound',
        'imageUrl': 'https://example.com/elastography.jpg',
        'content':
            'Ultrasound elastography has emerged as a valuable non-invasive tool for assessing liver fibrosis and cirrhosis. This article examines different elastography techniques, interpretation criteria, and their role in clinical decision-making for patients with chronic liver disease, potentially reducing the need for invasive liver biopsies.',
        'isBookmarked': true,
      },
    ];

    final bookmarkedArticles = recentArticles
        .where((article) => article['isBookmarked'] == true)
        .toList();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _categories = categories;
        _recentArticles = recentArticles;
        _bookmarkedArticles = bookmarkedArticles;
      });
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    // Combine all articles for searching
    final allArticles = [..._recentArticles];

    // Filter articles based on search query
    final results = allArticles.where((article) {
      final title = article['title'].toString().toLowerCase();
      final category = article['category'].toString().toLowerCase();
      final author = article['author'].toString().toLowerCase();
      final content = article['content'].toString().toLowerCase();

      final searchQuery = query.toLowerCase();

      return title.contains(searchQuery) ||
          category.contains(searchQuery) ||
          author.contains(searchQuery) ||
          content.contains(searchQuery);
    }).toList();

    setState(() {
      _isSearching = true;
      _searchResults = results;
    });
  }

  void _viewArticle(Map<String, dynamic> article) {
    context.push('/article-detail', extra: article);
  }

  void _viewCategory(Map<String, dynamic> category) {
    context.push('/category-articles', extra: category);
  }

  void _toggleBookmark(Map<String, dynamic> article) {
    setState(() {
      article['isBookmarked'] = !(article['isBookmarked'] as bool);

      // Update bookmarked articles list
      if (article['isBookmarked']) {
        _bookmarkedArticles.add(article);
      } else {
        _bookmarkedArticles.removeWhere((item) => item['id'] == article['id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050A30),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search for articles...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _performSearch,
              )
            : const Text(
                'Radiology Knowledge Base',
                style: TextStyle(color: Colors.white),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _isSearching = false;
                  _searchResults = [];
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSearching
              ? _buildSearchResults()
              : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isSearching = true;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Search for articles, topics, or references...',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Categories
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: InkWell(
                  onTap: () => _viewCategory(category),
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 32,
                          color: Color(category['color']),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${category['articles']} articles',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Recent Articles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Articles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all recent articles
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentArticles.length,
            itemBuilder: (context, index) {
              final article = _recentArticles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: InkWell(
                  onTap: () => _viewArticle(article),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Article thumbnail (placeholder)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        article['category'],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    article['date'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                article['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                article['author'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      article['isBookmarked']
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: article['isBookmarked']
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                    onPressed: () => _toggleBookmark(article),
                                    iconSize: 20,
                                    splashRadius: 20,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.share_outlined,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      // Share article
                                    },
                                    iconSize: 20,
                                    splashRadius: 20,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Bookmarked Articles
          const Text(
            'Bookmarked Articles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _bookmarkedArticles.isEmpty
              ? _buildEmptyState(
                  'No bookmarked articles',
                  'Articles you bookmark will appear here for easy access',
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _bookmarkedArticles.length,
                  itemBuilder: (context, index) {
                    final article = _bookmarkedArticles[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.article_outlined,
                          color: Colors.blue[700],
                        ),
                      ),
                      title: Text(
                        article['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        article['category'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark, color: Colors.blue),
                        onPressed: () => _toggleBookmark(article),
                      ),
                      onTap: () => _viewArticle(article),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.isEmpty) {
      return const Center(
        child: Text('Enter a search query'),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No results found for "${_searchController.text}"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try different keywords or browse by category',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final article = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              article['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['author'],
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    article['category'],
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                article['isBookmarked']
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: article['isBookmarked'] ? Colors.blue : null,
              ),
              onPressed: () => _toggleBookmark(article),
            ),
            onTap: () => _viewArticle(article),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bookmark_border,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({
    required this.article,
    Key? key, // Add key parameter to constructor
  }) : super(key: key);

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late Map<String, dynamic> _article;
  bool _isBookmarked = false;
  double _fontSize = 16.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _isBookmarked = _article['isBookmarked'] ?? false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      _article['isBookmarked'] = _isBookmarked;
    });
  }

  // Add the _buildBottomBarItem method to this class
  Widget _buildBottomBarItem(
      IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF050A30),
        title: const Text(
          'Article',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Share article
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Sharing functionality to be implemented')),
              );
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Increase font size'),
                onTap: () {
                  setState(() {
                    if (_fontSize < 24.0) {
                      _fontSize += 2.0;
                    }
                  });
                },
              ),
              PopupMenuItem(
                child: const Text('Decrease font size'),
                onTap: () {
                  setState(() {
                    if (_fontSize > 12.0) {
                      _fontSize -= 2.0;
                    }
                  });
                },
              ),
              PopupMenuItem(
                child: const Text('Download PDF'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF download started')),
                  );
                },
              ),
              PopupMenuItem(
                child: const Text('Copy citation'),
                onTap: () {
                  final citation =
                      '${_article['author']}, "${_article['title']}", ${_article['date']}';
                  Clipboard.setData(ClipboardData(text: citation));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Citation copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _article['category'],
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Article title
            Text(
              _article['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Article metadata
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _article['author'],
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 4),
                Text(
                  _article['date'],
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Article image placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Article content
            Text(
              _article['content'],
              style: TextStyle(
                fontSize: _fontSize,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 24),

            // References section
            const Text(
              'References',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Johnson A, et al. "Advanced MRI Techniques in Neurological Disorders." Journal of Radiology, 2024; 56(3): 234-248.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              '2. Smith B, et al. "Comparison of High-Resolution MRI Methods for Brain Imaging." Radiology Reviews, 2024; 35(2): 112-126.',
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 32),

            // Related articles section
            const Text(
              'Related Articles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Related article cards
            const Card(
              child: ListTile(
                leading: Icon(Icons.article),
                title: Text('Diffusion Tensor Imaging in Multiple Sclerosis'),
                subtitle: Text('Dr. Rebecca Chen'),
              ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.article),
                title: Text('Brain MRI Protocols for Dementia Screening'),
                subtitle: Text('Dr. Michael Taylor'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 100, // Set explicit height for the BottomAppBar
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 4), // Reduced vertical padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomBarItem(Icons.thumb_up_outlined, 'Like', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Article liked')),
                );
              }),
              _buildBottomBarItem(Icons.comment_outlined, 'Comment', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Comments section to be implemented')),
                );
              }),
              _buildBottomBarItem(Icons.save_outlined, 'Save', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Article saved for offline reading')),
                );
              }),
              _buildBottomBarItem(Icons.print_outlined, 'Print', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Print functionality to be implemented')),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: const Color(0xFF050A30),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}

class CategoryArticlesScreen extends StatefulWidget {
  final Map<String, dynamic> category;

  const CategoryArticlesScreen({
    required this.category,
    Key? key, // Add key parameter to constructor
  }) : super(key: key);

  @override
  _CategoryArticlesScreenState createState() => _CategoryArticlesScreenState();
}

class _CategoryArticlesScreenState extends State<CategoryArticlesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock articles for this category
    final articles = [
      {
        'id': 'art101',
        'title':
            '${widget.category['name']} Imaging Techniques: A Comprehensive Guide',
        'author': 'Dr. Robert Miller',
        'date': '2025-04-20',
        'category': widget.category['name'],
        'isBookmarked': false,
        'content':
            'This comprehensive article covers all aspects of ${widget.category['name']} imaging techniques, from basic principles to advanced applications.',
      },
      {
        'id': 'art102',
        'title':
            'Clinical Applications of ${widget.category['name']} in Oncology',
        'author': 'Dr. Jennifer Adams',
        'date': '2025-04-15',
        'category': widget.category['name'],
        'isBookmarked': true,
        'content':
            'This article explores how ${widget.category['name']} imaging is revolutionizing cancer detection, staging, and treatment monitoring.',
      },
      {
        'id': 'art103',
        'title': 'Quality Control in ${widget.category['name']} Imaging',
        'author': 'Dr. Thomas Zhang',
        'date': '2025-04-10',
        'category': widget.category['name'],
        'isBookmarked': false,
        'content':
            'Maintaining high standards in ${widget.category['name']} imaging is essential for accurate diagnosis. This article covers key quality control procedures.',
      },
      {
        'id': 'art104',
        'title': 'Pediatric ${widget.category['name']} Protocols',
        'author': 'Dr. Sarah Johnson',
        'date': '2025-03-28',
        'category': widget.category['name'],
        'isBookmarked': false,
        'content':
            'Adapting ${widget.category['name']} techniques for pediatric patients requires special considerations. Learn about optimal protocols for different age groups.',
      },
      {
        'id': 'art105',
        'title': 'Recent Advances in ${widget.category['name']} Technology',
        'author': 'Dr. Michael Chen',
        'date': '2025-03-22',
        'category': widget.category['name'],
        'isBookmarked': true,
        'content':
            'The field of ${widget.category['name']} imaging is constantly evolving. This article highlights the most significant technological developments in the past year.',
      },
    ];

    if (mounted) {
      setState(() {
        _isLoading = false;
        _articles = articles;
      });
    }
  }

  void _toggleBookmark(Map<String, dynamic> article) {
    setState(() {
      article['isBookmarked'] = !(article['isBookmarked'] as bool);
    });
  }

  void _viewArticle(Map<String, dynamic> article) {
    context.push('/article-detail', extra: article);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF050A30),
        title: Text(
          widget.category['name'],
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Implement search within category
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Implement filtering
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Category info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF050A30).withOpacity(0.05),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(widget.category['color']),
                        radius: 24,
                        child: Icon(
                          widget.category['icon'] as IconData,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.category['articles']} articles',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Article list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _articles.length,
                    itemBuilder: (context, index) {
                      final article = _articles[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            article['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                article['author'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                article['date'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                article['content'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              article['isBookmarked']
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color:
                                  article['isBookmarked'] ? Colors.blue : null,
                            ),
                            onPressed: () => _toggleBookmark(article),
                          ),
                          onTap: () => _viewArticle(article),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
