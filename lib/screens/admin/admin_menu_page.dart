import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_survey_app/models/menu_item.dart';
import 'package:restaurant_survey_app/screens/admin/admin_review_page.dart';
import 'package:restaurant_survey_app/services/database_service.dart';
import 'package:restaurant_survey_app/widgets/language_switcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  List<MenuItem> _menuItems = [];
  String _sortOption = 'highest_to_lowest';
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = true;

  // palette (same family used across the app)
  static const _cream = Color(0xFFFFF7ED);
  static const _terracotta = Color(0xFFCC6B49);
  static const _ink = Color(0xFF232222);

  @override
  void initState() {
    super.initState();
    _loadMenuItemsWithRatings();
  }

  Future<void> _loadMenuItemsWithRatings() async {
    try {
      final items = await DatabaseService.getAllMenuItems();

      for (var item in items) {
        final res =
        await _supabase.from('reviews').select('rating').eq('menu_item_id', item.menuItemId);

        if (res.isNotEmpty) {
          final ratings = res.map((r) => (r['rating'] as num).toDouble()).toList();
          item.averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
        } else {
          item.averageRating = 0.0;
        }
      }

      setState(() {
        _menuItems = items;
        _sortMenuItems();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading data: $e")),
        );
      }
    }
  }

  void _sortMenuItems() {
    _menuItems.sort((a, b) {
      return _sortOption == 'highest_to_lowest'
          ? b.averageRating.compareTo(a.averageRating)
          : a.averageRating.compareTo(b.averageRating);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'menu_reviews'.tr,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [LanguageSwitcher()],
        centerTitle: true,
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

      body: Stack(
        children: [
          // Background gradient + subtle glows
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
            child: _blurCircle(isDark ? const Color(0x33FFFFFF) : const Color(0x33CC6B49), 150),
          ),
          Positioned(
            bottom: -70,
            left: -50,
            child: _blurCircle(isDark ? const Color(0x334CAF50) : const Color(0x337A8F55), 190),
          ),

          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              // Sort controls (unchanged logic; styled)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF232021) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color:
                        isDark ? const Color(0x26FFFFFF) : const Color(0x14000000)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'sort_by_rating'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : _ink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _sortOption,
                        underline: const SizedBox.shrink(),
                        dropdownColor: isDark ? const Color(0xFF2B2727) : Colors.white,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                        items: [
                          DropdownMenuItem(
                            value: 'highest_to_lowest',
                            child: Text('highest_to_lowest'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'lowest_to_highest',
                            child: Text('lowest_to_highest'.tr),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortOption = value!;
                            _sortMenuItems();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Menu items list (logic unchanged)
              Expanded(
                child: ListView.builder(
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: isDark ? const Color(0xFF232021) : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0x26FFFFFF)
                              : const Color(0x14000000),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          item.getLocalizedName(),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : _ink,
                          ),
                        ),
                        subtitle: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              ' ${item.averageRating.toStringAsFixed(1)}'.tr,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward,
                            color: isDark ? Colors.white70 : Colors.black45),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminReviewPage(menuItem: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // tiny helper for background glows
  static Widget _blurCircle(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 10)],
    ),
  );
}
