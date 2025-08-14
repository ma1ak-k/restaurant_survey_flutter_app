import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:restaurant_survey_app/widgets/language_switcher.dart';
import 'dart:convert';
import '../../models/menu_item.dart';
import '../../services/database_service.dart';

String _normalizeText(String input) {
  final lower = input.toLowerCase();

  // Remove punctuation & symbols
  final noPunct = lower.replaceAll(
    RegExp(r'[^\p{L}\p{N}\s]', unicode: true),
    '',
  );

  // Remove Arabic diacritics (tashkeel)
  final noDiacritics = noPunct.replaceAll(
    RegExp(r'[\u064B-\u0652\u0670\u0640]', unicode: true),
    '',
  );

  // Trim extra spaces
  return noDiacritics.replaceAll(RegExp(r'\s+'), ' ').trim();
}

class MultiReviewPage extends StatefulWidget {
  final List<MenuItem> selectedItems;

  const MultiReviewPage({super.key, required this.selectedItems});

  @override
  State<MultiReviewPage> createState() => _MultiReviewPageState();
}

class _MultiReviewPageState extends State<MultiReviewPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final Map<int, double> _ratings = {};
  final Map<int, TextEditingController> _commentControllers = {};

  List<String> _badWords = [];
  List<String> _goodWords = [];

  @override
  void initState() {
    super.initState();
    _loadWordLists();
    for (var item in widget.selectedItems) {
      _commentControllers[item.menuItemId] = TextEditingController();
      _ratings[item.menuItemId] = 0.0;
    }
  }

  Future<void> _loadWordLists() async {
    String jsonString = await rootBundle.loadString('assets/words.json');
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    _badWords = List<String>.from(
      jsonMap['negative_words'],
    ).map((w) => _normalizeText(w)).toList();

    _goodWords = List<String>.from(
      jsonMap['positive_words'],
    ).map((w) => _normalizeText(w)).toList();
  }

  bool _isReviewValid(String review, double rating) {
    final normalizedReview = _normalizeText(review);

    bool containsBadWord = _badWords.any(
          (word) => normalizedReview.contains(word),
    );
    bool containsGoodWord = _goodWords.any(
          (word) => normalizedReview.contains(word),
    );

    if (rating >= 4 && containsBadWord) return false;
    if (rating <= 2 && containsGoodWord) return false;

    return true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitAllReviews() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      _showError('please_enter_name_phone'.tr);
      return;
    }

    // Validate phone number format (Egyptian format)
    final phoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');
    if (!phoneRegex.hasMatch(_phoneController.text.trim())) {
      _showError('please_enter_phone'.tr);
      return;
    }

    for (var item in widget.selectedItems) {
      final rating = _ratings[item.menuItemId] ?? 0.0;
      if (rating == 0.0) {
        _showError('please_rate_all'.tr);
        return;
      }
      final comment = _commentControllers[item.menuItemId]!.text.trim();
      if (!_isReviewValid(comment, rating)) {
        _showError(
          "Rating and review for '${item.mealName}' do not match. Please fix it.",
        );
        return;
      }
    }

    try {
      List<ReviewData> reviews = widget.selectedItems.map((item) {
        return ReviewData(
          menuItemId: item.menuItemId,
          rating: _ratings[item.menuItemId]!,
          comment: _commentControllers[item.menuItemId]!.text.trim(),
        );
      }).toList();

      await DatabaseService.submitMultipleReviews(
        userName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        reviews: reviews,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                      (route) => false,
                ); // Go home
              }
            });
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Center(
                child: Text(
                  'thank_you'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: Colors.red, size: 60),
                  SizedBox(height: 16),
                  Text('reviews_submitted'.tr, textAlign: TextAlign.center),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      _showError('${'error_submitting'.tr}: $e');
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
                        item.getLocalizedName(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'egp ${item.price.toStringAsFixed(2)}'.tr,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.getLocalizedDescription(),
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
            Text(
              '${'rate_dish'.tr}: *',
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
            TextField(
              controller: _commentControllers[item.menuItemId],
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'add_comment'.tr,
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
        title: Text('review_selected_dishes'.tr),
        actions: [LanguageSwitcher()],
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'enter_details'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "${'name'.tr} *",
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
                        labelText: "${'phone'.tr} *",
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
            Text(
              'rate_each_item'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...widget.selectedItems.map((item) => _buildItemReviewCard(item)),
            const SizedBox(height: 20),
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
                  'submit_reviews'.tr,
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
