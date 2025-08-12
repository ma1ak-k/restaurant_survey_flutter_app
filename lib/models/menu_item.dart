class MenuItem {
  final int menuItemId;
  final String mealName;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  MenuItem({
    required this.menuItemId,
    required this.mealName,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuItemId: json['menu_item_id'] as int,
      mealName: json['meal_name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String,
      category: json['category'] as String,
    );
  }
}

class User {
  final int userId;
  final String userName;
  final String phone;
  final DateTime? createdAt;

  User({
    required this.userId,
    required this.userName,
    required this.phone,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      phone: json['phone'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

class Review {
  final int reviewId;
  final int userId;
  final int menuItemId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final User? user;
  final MenuItem? menuItem;

  Review({
    required this.reviewId,
    required this.userId,
    required this.menuItemId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.user,
    this.menuItem,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'] as int,
      userId: json['user_id'] as int,
      menuItemId: json['menu_item_id'] as int,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at']),
      user: json['users'] != null ? User.fromJson(json['users']) : null,
      menuItem: json['menu'] != null ? MenuItem.fromJson(json['menu']) : null,
    );
  }
}
