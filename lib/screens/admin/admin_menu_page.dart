import 'package:flutter/material.dart';
import 'package:restaurant_survey_app/models/menu_item.dart';
import 'package:restaurant_survey_app/services/database_service.dart';
import 'package:restaurant_survey_app/screens/admin/admin_review_page.dart';

class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  List<MenuItem> _menuItems = [];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    try {
      final items = await DatabaseService.getAllMenuItems();

      setState(() {
        _menuItems = items;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load menu items: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Item to View Reviews')),
      body: _menuItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return ListTile(
            title: Text(item.mealName),
            subtitle: Text('Price: ${item.price} EGP'),
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
    );
  }
}
