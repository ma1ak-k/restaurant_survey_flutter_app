import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:restaurant_survey_app/models/menu_item.dart';
import 'package:restaurant_survey_app/services/database_service.dart';

class MenuItemReviewPage extends StatefulWidget {
  const MenuItemReviewPage({super.key});

  @override
  State<MenuItemReviewPage> createState() => _MenuItemReviewPageState();
}

class _MenuItemReviewPageState extends State<MenuItemReviewPage> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _submitReview() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in name, phone and rating")),
      );
      return;
    }

    final menuItem = Get.arguments as MenuItem;

    try {
      // Submit single review using database service
      await DatabaseService.submitMultipleReviews(
        userName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        reviews: [
          ReviewData(
            menuItemId: menuItem.menuItemId,
            rating: _rating,
            comment: _reviewController.text.trim(),
          ),
        ],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review submitted successfully!")),
        );

        // Navigate to home page after successful submission
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/', // Home route
              (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItem = Get.arguments as MenuItem; // Passed from previous screen

    return Scaffold(
      appBar: AppBar(
        title: Text(menuItem.mealName),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                menuItem.imageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Name, description, price
            Text(
              menuItem.mealName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              menuItem.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${menuItem.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            // Rating bar
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),

            // Review text field
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Your review or suggestion",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Your name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Phone field
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "Your phone",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Submit button
            //INSERT INTO DATABASE TABLE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Submit Review",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
