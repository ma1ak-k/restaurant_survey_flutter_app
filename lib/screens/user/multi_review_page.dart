import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:restaurant_survey_app/widgets/language_switcher.dart';
import 'dart:convert';
import '../../models/menu_item.dart';
import '../../services/database_service.dart';

//helpers
String _normalizeText(String input) {
  final lower = input.toLowerCase();
  final noPunct = lower.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '');
  final noDiacritics =
  noPunct.replaceAll(RegExp(r'[\u064B-\u0652\u0670\u0640]', unicode: true), '');
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

  // palette
  static const _cream = Color(0xFFFFF7ED);
  static const _terracotta = Color(0xFFCC6B49);
  static const _plum = Color(0xFF5B3A3A);
  static const _ink = Color(0xFF232222);

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
    _badWords =
        List<String>.from(jsonMap['negative_words']).map((w) => _normalizeText(w)).toList();
    _goodWords =
        List<String>.from(jsonMap['positive_words']).map((w) => _normalizeText(w)).toList();
  }

  bool _isReviewValid(String review, double rating) {
    final normalizedReview = _normalizeText(review);
    bool containsBadWord = _badWords.any((word) => normalizedReview.contains(word));
    bool containsGoodWord = _goodWords.any((word) => normalizedReview.contains(word));
    if (rating >= 4 && containsBadWord) return false;
    if (rating <= 2 && containsGoodWord) return false;
    return true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    for (var c in _commentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submitAllReviews() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      _showError('please_enter_name_phone'.tr);
      return;
    }
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
        _showError("Rating and review for '${item.mealName}' do not match. Please fix it.");
        return;
      }
    }

    try {
      List<ReviewData> reviews = widget.selectedItems
          .map((item) => ReviewData(
        menuItemId: item.menuItemId,
        rating: _ratings[item.menuItemId]!,
        comment: _commentControllers[item.menuItemId]!.text.trim(),
      ))
          .toList();

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
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            });
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Center(
                child: Text('thank_you'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? const Color(0xFF232021) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? const Color(0x26FFFFFF) : const Color(0x14000000),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: isDark ? const Color(0xFF2B2727) : Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: isDark ? const Color(0xFF2B2727) : Colors.grey[200],
                      child: Icon(Icons.fastfood, color: isDark ? Colors.white54 : Colors.grey),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
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
                          fontSize: 12,
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
            const SizedBox(height: 16),
            Text('${'rate_dish'.tr}: *', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                filled: true,
                fillColor: isDark ? const Color(0x1AFFFFFF) : const Color(0x0DCC6B49),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0x26FFFFFF) : const Color(0x33CC6B49),
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Gradient AppBar
      appBar: AppBar(
        title: Text(
          'review_selected_dishes'.tr,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [LanguageSwitcher()],
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
          // background gradient + soft glows
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                isDark ? const [Color(0xFF161414), Color(0xFF1E1B1B)] : const [_cream, Color(0xFFFFEFE0)],
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

          // main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // details card
                Card(
                  color: isDark ? const Color(0xFF232021) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isDark ? const Color(0x26FFFFFF) : const Color(0x14000000),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('enter_details'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : _ink,
                            )),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          decoration: _inputDecoration(
                            context,
                            label: "${'name'.tr} *",
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(
                            context,
                            label: "${'phone'.tr} *",
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text('rate_each_item'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : _ink,
                    )),
                const SizedBox(height: 10),

                ...widget.selectedItems.map((item) => _buildItemReviewCard(item)),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitAllReviews,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _terracotta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'submit_reviews'.tr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context,
      {required String label, required bool isDark}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      filled: true,
      fillColor: isDark ? const Color(0x1AFFFFFF) : const Color(0x0DCC6B49),
      contentPadding: const EdgeInsets.all(12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? const Color(0x26FFFFFF) : const Color(0x33CC6B49),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? Colors.white70 : _terracotta,
          width: 1.2,
        ),
      ),
    );
  }

  // helpers
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
