import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/menu_item.dart';
import '../../services/database_service.dart';
import 'multi_review_page.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItem> _allMenuItems = [];
  late List<MenuItem> _displayedItems;
  List<MenuItem> _selectedItems = []; // Track selected items for multi-review
  bool _isLoading = true;
  String? _error;
  bool _isGridView = false;
  String _selectedCategory = 'Main Course';

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load all menu items from database
      _allMenuItems = await DatabaseService.getAllMenuItems();

      // Filter by selected category and sort by menu_item_id to ensure proper ordering
      setState(() {
        _displayedItems =
        _allMenuItems
            .where((item) => item.category == _selectedCategory)
            .toList()
          ..sort(
                (a, b) => a.menuItemId.compareTo(b.menuItemId),
          ); // Ensure ascending order
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load menu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _displayedItems =
      _allMenuItems.where((item) => item.category == category).toList()
        ..sort(
              (a, b) => a.menuItemId.compareTo(b.menuItemId),
        ); // Ensure ascending order
    });
  }

  Widget _buildCategoryButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCategoryButton('Main Course'),
        const SizedBox(width: 16),
        _buildCategoryButton('Dessert'),
      ],
    );
  }

  Widget _buildCategoryButton(String category) {
    return ElevatedButton(
      onPressed: () => _filterByCategory(category),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedCategory == category
            ? Theme.of(context).primaryColor
            : Colors.grey[300],
        foregroundColor: _selectedCategory == category
            ? Colors.white
            : Colors.black,
      ),
      child: Text(category),
    );
  }

  // Multi-selection methods
  void _toggleItemSelection(MenuItem item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  void _goToMultiReview() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item to review'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiReviewPage(selectedItems: _selectedItems),
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    final isSelected = _selectedItems.contains(item);

    if (!_isGridView) {
      // List View Layout
      final cardWidget = Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected ? Colors.orange[100] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection indicator
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  color: isSelected ? Colors.green : Colors.grey,
                  size: 24,
                ),
              ),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.mealName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'EGP ${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      return InkWell(
        onTap: () => _toggleItemSelection(item),
        child: cardWidget,
      );
    } else {
      // Grid View Layout
      final cardWidget = Card(
        margin: const EdgeInsets.all(4),
        color: isSelected ? Colors.orange[100] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selection indicator overlay
            Stack(
              children: [
                // Image Container with proper centering
                Container(
                  height: 120,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center, // Ensure image is centered
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                // Selection indicator
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.mealName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Price prominently displayed at bottom
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'EGP ${item.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      return InkWell(
        onTap: () => _toggleItemSelection(item),
        child: cardWidget,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Menu'),
        actions: [
          // Cart icon with badge
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (_selectedItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${_selectedItems.length}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _goToMultiReview,
            tooltip: 'Review selected items (${_selectedItems.length})',
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category selector
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _buildCategoryButtons(),
          ),

          // Main content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : _displayedItems.isEmpty
                ? const Center(child: Text('No items in this category'))
                : _isGridView
                ? GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio:
                0.85, // Better aspect ratio for grid items
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _displayedItems.length,
              itemBuilder: (context, index) =>
                  _buildMenuItemCard(_displayedItems[index]),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _displayedItems.length,
              itemBuilder: (context, index) =>
                  _buildMenuItemCard(_displayedItems[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedItems.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _goToMultiReview,
        icon: Icon(Icons.rate_review),
        label: Text('Review ${_selectedItems.length} items'),
        backgroundColor: Colors.deepPurple,
      )
          : null,
    );
  }
}
