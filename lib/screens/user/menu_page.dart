import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
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
  final List<MenuItem> _selectedItems = [];
  bool _isLoading = true;
  String? _error;
  bool _isGridView = false;
  String _selectedCategory = 'Main Course';

  // palette
  static const _cream = Color(0xFFFFF7ED);
  static const _terracotta = Color(0xFFCC6B49);
  static const _plum = Color(0xFF5B3A3A);
  static const _ink = Color(0xFF232222);

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

      _allMenuItems = await DatabaseService.getAllMenuItems();

      setState(() {
        _displayedItems = _allMenuItems
            .where((item) => item.category == _selectedCategory)
            .toList()
          ..sort((a, b) => a.menuItemId.compareTo(b.menuItemId));
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
        ..sort((a, b) => a.menuItemId.compareTo(b.menuItemId));
    });
  }

  String _translateCategory(String category) {
    switch (category) {
      case 'Main Course':
        return 'main_course'.tr;
      case 'Dessert':
        return 'dessert'.tr;
      default:
        return category;
    }
  }

  Widget _buildCategoryButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildCategoryButton('Main Course'),
        _buildCategoryButton('Dessert'),
      ],
    );
  }

  Widget _buildCategoryButton(String category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _selectedCategory == category;
    final bg = selected
        ? _terracotta
        : (isDark ? const Color(0xFF2A2524) : Colors.white);
    final fg =
    selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87);
    final border = selected
        ? Colors.transparent
        : (isDark ? const Color(0x26FFFFFF) : const Color(0x14000000));

    return ElevatedButton(
      onPressed: () => _filterByCategory(category),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: border),
        ),
      ),
      child: Text(
        _translateCategory(category),
        style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: .2),
      ),
    );
  }

  // Multi-selection
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('no_items_selected'.tr)));
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isGridView) {
      // LIST VIEW
      final cardWidget = Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected
            ? (isDark ? const Color(0x3322FF88) : const Color(0xFFFFF0E3))
            : (isDark ? const Color(0xFF232021) : Colors.white),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected
                ? (isDark ? const Color(0x5522FF88) : const Color(0x33CC6B49))
                : (isDark ? const Color(0x26FFFFFF) : const Color(0x14000000)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // selection icon
              Container(
                margin: const EdgeInsets.only(right: 12, top: 4),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  color: isSelected
                      ? (isDark ? const Color(0xFF7ED957) : Colors.green)
                      : (isDark ? Colors.white54 : Colors.grey),
                  size: 24,
                ),
              ),
              // image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 84,
                    height: 84,
                    color: isDark ? const Color(0xFF2B2727) : Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 84,
                    height: 84,
                    color: isDark ? const Color(0xFF2B2727) : Colors.grey[200],
                    child: Icon(Icons.fastfood,
                        color: isDark ? Colors.white54 : Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.getLocalizedName(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : _ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${'egp'.tr} ${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF8BE28E) : Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.getLocalizedDescription(),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.25,
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
      return InkWell(onTap: () => _toggleItemSelection(item), child: cardWidget);
    } else {
      // GRID VIEW
      final cardWidget = Card(
        margin: const EdgeInsets.all(4),
        color: isSelected
            ? (isDark ? const Color(0x3322FF88) : const Color(0xFFFFF0E3))
            : (isDark ? const Color(0xFF232021) : Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // image + selection indicator
            Stack(
              children: [
                Container(
                  height: 120,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    placeholder: (context, url) => Container(
                      color: isDark ? const Color(0xFF2B2727) : Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: isDark ? const Color(0xFF2B2727) : Colors.grey[200],
                      child: Icon(Icons.fastfood,
                          size: 40,
                          color: isDark ? Colors.white54 : Colors.grey),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color:
                        isDark ? const Color(0xFF7ED957) : Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
            // details
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
                          item.getLocalizedName(),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: isDark ? Colors.white : _ink,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.getLocalizedDescription(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                        (isDark ? Colors.white : _terracotta).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0x26FFFFFF)
                              : const Color(0x33CC6B49),
                        ),
                      ),
                      child: Text(
                        '${'egp'.tr} ${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF8BE28E) : Colors.green,
                          fontWeight: FontWeight.w700,
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
      return InkWell(onTap: () => _toggleItemSelection(item), child: cardWidget);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Gradient AppBar
      appBar: AppBar(
        title: Text('restaurant_menu'.tr,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700,
            )),
        actions: [
          // Cart icon with badge
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_cart,
                    color: isDark ? Colors.white : Colors.black87),
                if (_selectedItems.isNotEmpty)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${_selectedItems.length}',
                        style:
                        const TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _goToMultiReview,
            tooltip: '${'review_selected_items'.tr} (${_selectedItems.length})',
          ),
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'list_view'.tr : 'grid_view'.tr,
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF2A1E1A), Color(0xFF3A2A25)]
                  : const [Color(0xFFFFE4C7), Color(0xFFF8C9A8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),

      // Themed background
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [Color(0xFF161414), Color(0xFF1E1B1B)]
                    : const [_cream, Color(0xFFFFEFE0)],
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -40,
            child: _blurCircle(
                isDark ? const Color(0x33FFFFFF) : const Color(0x33CC6B49),
                150),
          ),
          Positioned(
            bottom: -70,
            left: -50,
            child: _blurCircle(
                isDark ? const Color(0x334CAF50) : const Color(0x337A8F55),
                190),
          ),

          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _buildCategoryButtons(),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                    child: Text(_error!,
                        style: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : Colors.black87)))
                    : _displayedItems.isEmpty
                    ? Center(
                  child: Text('No items in this category'.tr,
                      style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : Colors.black87)),
                )
                    : _isGridView
                    ? GridView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(8, 8, 8, 88),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                    _gridAspectRatio(context), // responsive fix
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: _displayedItems.length,
                  itemBuilder: (context, index) =>
                      _buildMenuItemCard(
                          _displayedItems[index]),
                )
                    : ListView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(12, 8, 12, 88),
                  itemCount: _displayedItems.length,
                  itemBuilder: (context, index) =>
                      _buildMenuItemCard(
                          _displayedItems[index]),
                ),
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: _selectedItems.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _goToMultiReview,
        icon: const Icon(Icons.rate_review),
        label: Text(
          '${'review_selected_items'.tr} (${_selectedItems.length})',
        ),
        backgroundColor: _terracotta,
        foregroundColor: Colors.white,
      )
          : null,
    );
  }

  //fixing ratio for tiles
  double _gridAspectRatio(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    const columns = 2;
    const outerPadding = 16.0;
    const spacing = 12.0;

    final tileW = (screenW - outerPadding - (columns - 1) * spacing) / columns;

    final textScale = MediaQuery.of(context).textScaleFactor;
    final desiredH =
    (275.0 * (textScale > 1.1 ? textScale : 1.0)); // target height

    return tileW / desiredH;
  }

  // helpers
  static Widget _blurCircle(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(color: color, blurRadius: 60, spreadRadius: 10),
      ],
    ),
  );
}
