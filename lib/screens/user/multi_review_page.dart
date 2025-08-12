import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/menu_item.dart';
import '../../services/database_service.dart';

class MultiReviewPage extends StatefulWidget {
  final List<MenuItem> selectedItems;

  const MultiReviewPage({super.key, required this.selectedItems});

  @override
  State<MultiReviewPage> createState() => _MultiReviewPageState();
}

class _MultiReviewPageState extends State<MultiReviewPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Store ratings and comments for each selected item
  final Map<int, double> _ratings = {};
  final Map<int, TextEditingController> _commentControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers and ratings for each item
    for (var item in widget.selectedItems) {
      _commentControllers[item.menuItemId] = TextEditingController();
      _ratings[item.menuItemId] = 0.0; // Default no rating
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _phoneController.dispose();
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitAllReviews() async {
    // Validation
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      _showError("Please enter your name and phone number");
      return;
    }

    // Check all items have ratings
    for (var item in widget.selectedItems) {
      if (_ratings[item.menuItemId] == 0.0) {
        _showError("Please rate all selected items");
        return;
      }
    }

    try {
      // Prepare review data
      List<ReviewData> reviews = widget.selectedItems.map((item) {
        return ReviewData(
          menuItemId: item.menuItemId,
          rating: _ratings[item.menuItemId]!,
          comment: _commentControllers[item.menuItemId]!.text.trim(),
        );
      }).toList();

      // Submit all reviews
      await DatabaseService.submitMultipleReviews(
        userName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        reviews: reviews,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "All ${reviews.length} reviews submitted successfully!",
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home page (root of navigation stack)
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/', // Home route
              (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      _showError('Failed to submit reviews: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildItemReviewCard(MenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.mealName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'EGP ${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 12,
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

            const SizedBox(height: 16),

            // Rating
            Text(
              'Rate this item: *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: _ratings[item.menuItemId] ?? 0.0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _ratings[item.menuItemId] = rating;
                });
              },
            ),

            const SizedBox(height: 16),

            // Comment
            TextField(
              controller: _commentControllers[item.menuItemId],
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Comment (optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
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
        title: Text('Review ${widget.selectedItems.length} Items'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info section (only once at top)
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Your Name *",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: "Your Phone *",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Reviews section header
            Text(
              'Rate each item:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Review section for each selected item
            ...widget.selectedItems.map((item) => _buildItemReviewCard(item)),

            const SizedBox(height: 20),

            // Submit all button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitAllReviews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Submit All ${widget.selectedItems.length} Reviews',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
