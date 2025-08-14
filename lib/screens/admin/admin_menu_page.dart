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

  @override
  void initState() {
    super.initState();
    _loadMenuItemsWithRatings();
  }

  Future<void> _loadMenuItemsWithRatings() async {
    try {
      final items = await DatabaseService.getAllMenuItems();

      for (var item in items) {
        final res = await _supabase
            .from('reviews')
            .select('rating')
            .eq('menu_item_id', item.menuItemId);

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
    return Scaffold(
      appBar: AppBar(
        title: Text('menu_reviews'.tr),
        actions: [LanguageSwitcher()],
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Sort by rating label + dropdown
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                 Text(
                   'sort_by_rating'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _sortOption,
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

          // Menu items list
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return ListTile(
                  title: Text(item.getLocalizedName()),
                  subtitle: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(' ${item.averageRating.toStringAsFixed(1)}'.tr),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminReviewPage(menuItem: item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
