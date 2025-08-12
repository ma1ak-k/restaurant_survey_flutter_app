import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../models/menu_item.dart';
import 'rating_page.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItem> _allMenuItems = [];
  late List<MenuItem> _displayedItems;
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
      final jsonString = await rootBundle.loadString('assets/menu.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final menuData = jsonData['record']['menu'] as List;

      setState(() {
        _allMenuItems = menuData
            .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
            .toList();
        _displayedItems = _allMenuItems
            .where((item) => item.category == _selectedCategory)
            .toList();
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
      _displayedItems = _allMenuItems
          .where((item) => item.category == category)
          .toList();
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

  Widget _buildMenuItemCard(MenuItem item) {
    if (!_isGridView) {
      // List View Layout
      final cardWidget = Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      item.name,
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
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
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
        onTap: () => Get.to(() => MenuItemReviewPage(), arguments: item),
        child: cardWidget,
      );
    } else {
      // Grid View Layout (more compact)
      final cardWidget = Card(
        margin: const EdgeInsets.all(6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10)),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                height: 100,  // Reduced from 120 to make more compact
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 100,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fastfood),
                ),
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'EGP ${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 11,  // Smaller font for compact view
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      return InkWell(
        onTap: () => Get.to(() => MenuItemReviewPage(), arguments: item),
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
              padding: const EdgeInsets.all(6),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.4,  // More compact aspect ratio
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: _displayedItems.length,
              itemBuilder: (context, index) => _buildMenuItemCard(_displayedItems[index]),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _displayedItems.length,
              itemBuilder: (context, index) => _buildMenuItemCard(_displayedItems[index]),
            ),
          ),
        ],
      ),
    );
  }
}