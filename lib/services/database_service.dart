import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_item.dart';

class DatabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get all menu items
  static Future<List<MenuItem>> getAllMenuItems() async {
    try {
      final response = await _supabase
          .from('menu')
          .select()
          .order(
        'menu_item_id',
        ascending: true,
      ); // Explicitly set ascending order

      return (response as List).map((item) => MenuItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load menu items: $e');
    }
  }

  // Get menu items by category
  static Future<List<MenuItem>> getMenuItemsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('menu')
          .select()
          .eq('category', category)
          .order(
        'menu_item_id',
        ascending: true,
      ); // Explicitly set ascending order

      return (response as List).map((item) => MenuItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load menu items by category: $e');
    }
  }

  // Check if user exists by phone, create if not
  static Future<int> getOrCreateUser(String name, String phone) async {
    try {
      // Check if user exists
      final existingUser = await _supabase
          .from('users')
          .select('user_id')
          .eq('phone', phone)
          .maybeSingle();

      if (existingUser != null) {
        return existingUser['user_id'] as int;
      }

      // Create new user
      final newUser = await _supabase
          .from('users')
          .insert({'user_name': name, 'phone': phone})
          .select('user_id')
          .single();

      return newUser['user_id'] as int;
    } catch (e) {
      throw Exception('Failed to get or create user: $e');
    }
  }

  // Submit multiple reviews
  static Future<void> submitMultipleReviews({
    required String userName,
    required String phone,
    required List<ReviewData> reviews,
  }) async {
    try {
      // Get or create user
      final userId = await getOrCreateUser(userName, phone);

      // Prepare review data
      final reviewsToInsert = reviews
          .map(
            (review) => {
          'user_id': userId,
          'menu_item_id': review.menuItemId,
          'rating': review.rating,
          'comment': review.comment,
        },
      )
          .toList();

      // Insert all reviews
      await _supabase.from('reviews').insert(reviewsToInsert);
    } catch (e) {
      throw Exception('Failed to submit reviews: $e');
    }
  }

  // Get reviews for a specific menu item
  static Future<List<Review>> getReviewsForMenuItem(int menuItemId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('*, users(user_name, phone)')
          .eq('menu_item_id', menuItemId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((review) => Review.fromJson(review))
          .toList();
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  // Get all reviews with menu and user info (for admin)
  static Future<List<Review>> getAllReviews() async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('*, users(user_name, phone), menu(meal_name)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((review) => Review.fromJson(review))
          .toList();
    } catch (e) {
      throw Exception('Failed to load all reviews: $e');
    }
  }

  // Get average rating for a menu item
  static Future<double> getAverageRating(int menuItemId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('rating')
          .eq('menu_item_id', menuItemId);

      if (response.isEmpty) return 0.0;

      final ratings = (response as List)
          .map((review) => (review['rating'] as num).toDouble())
          .toList();

      return ratings.reduce((a, b) => a + b) / ratings.length;
    } catch (e) {
      throw Exception('Failed to calculate average rating: $e');
    }
  }
}

// Helper class for review data
class ReviewData {
  final int menuItemId;
  final double rating;
  final String comment;

  ReviewData({
    required this.menuItemId,
    required this.rating,
    required this.comment,
  });
}
