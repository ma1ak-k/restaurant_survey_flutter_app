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

  // palette
  static const _cream = Color(0xFFFFF7ED);
  static const _terracotta = Color(0xFFCC6B49);
  static const _ink = Color(0xFF232222);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          menuItem.getLocalizedName().tr,
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

          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchReviews(menuItem.menuItemId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${'error'.tr}: ${snapshot.error}',
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                  ),
                );
              }

              final reviews = snapshot.data ?? [];

              // Sort reviews
              reviews.sort((a, b) => (a['rating'] as num).compareTo(b['rating'] as num));

              // Average rating
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
                    // Image card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : _ink,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      menuItem.getLocalizedDescription(),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Average rating container
                    // Average rating container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF232021) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0x26FFFFFF) : const Color(0x14000000),
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Slightly smaller stars on extra-narrow screens
                          final starSize = constraints.maxWidth < 360 ? 18.0 : 22.0;

                          return Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              // Constrain
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: constraints.maxWidth - (starSize * 5) - 50),
                                child: Text(
                                  'average_rating_colon'.tr,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : _ink,
                                  ),
                                ),
                              ),
                              RatingBarIndicator(
                                rating: avgRating,
                                itemBuilder: (context, index) =>
                                const Icon(Icons.star, color: Colors.amber),
                                itemCount: 5,
                                itemSize: starSize,
                              ),
                              Text(
                                avgRating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : _ink,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section title
                    Text(
                      'user_suggestions_lowest'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : _ink,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Reviews list
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        final userName = review['users']?['user_name'] ?? 'anonymous'.tr;
                        final rating = (review['rating'] as num).toDouble();
                        final comment = review['comment'] ?? '';

                        return Card(
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
                            leading: RatingBarIndicator(
                              rating: rating,
                              itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                              itemSize: 20,
                            ),
                            title: Text(
                              userName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : _ink,
                              ),
                            ),
                            subtitle: Text(
                              comment,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                height: 1.25,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // helper
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
