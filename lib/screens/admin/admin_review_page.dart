import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:restaurant_survey_app/widgets/language_switcher.dart';
import '../../models/menu_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminReviewPage extends StatelessWidget {
  final MenuItem menuItem;

  const AdminReviewPage({super.key, required this.menuItem});

  Future<List<Map<String, dynamic>>> fetchReviews(int menuItemId) async {
    final response = await Supabase.instance.client
        .from('reviews')
        .select('*, users(user_name)')
        .eq('menu_item_id', menuItemId);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(menuItem.getLocalizedName().tr),
        actions: [LanguageSwitcher()],
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchReviews(menuItem.menuItemId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${'error'.tr}: ${snapshot.error}'));
          }
          final reviews = snapshot.data ?? [];

          // // Sort reviews by lowest rating first
          reviews.sort(
                (a, b) => (a['rating'] as num).compareTo(b['rating'] as num),
          );

          // Calculate average rating
          final double avgRating = reviews.isNotEmpty
              ? reviews
              .map((r) => (r['rating'] as num).toDouble())
              .reduce((a, b) => a + b) /
              reviews.length
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menu Item Image
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

                // Name
                Text(
                  menuItem.getLocalizedName(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 SizedBox(height: 8),


                // Description
                Text(
                  menuItem.getLocalizedDescription(),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                 SizedBox(height: 20),

                // Average Rating
                Row(
                  children: [
                    Text(
                      'average_rating_colon'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    RatingBarIndicator(
                      rating: avgRating,
                      itemBuilder: (context, index) =>
                      const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // User Reviews
                Text(
                  'user_suggestions_lowest'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) =>
                  const Divider(height: 20, thickness: 1),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return ListTile(
                      leading: RatingBarIndicator(
                        rating: (review['rating'] as num).toDouble(),
                        itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.amber),
                        itemSize: 20,
                      ),
                      title: Text(
                        review['users']?['user_name'] ?? 'anonymous'.tr,
                      ),                      subtitle: Text(review['comment'] ?? ''),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
