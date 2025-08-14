import 'package:get/get.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      // Common
      'anonymous': 'Anonymous',
      'error': 'Error',
      'average_rating_colon': 'Average Rating:',
      'user_suggestions': 'User Suggestions (Lowest rating first):',
      'user_suggestions_lowest': 'User Suggestions (Lowest rating first):',
      'sort_by_rating': 'Sort by rating:',
      'highest_to_lowest': 'Highest to Lowest',
      'lowest_to_highest': 'Lowest to Highest',

      // Review Page
      'rate_each_item': 'Rate each item (1-5 stars)',
      'rate_item': 'Rate this item (1-5 stars)',
      'rate_overall': 'Overall Rating',
      'write_comment': 'Write your comment here (optional)',
      'submit_review': 'Submit Review',
      'submit_reviews': 'Submit Reviews',
      'submit_all_reviews': 'Submit All Reviews',
      'submit_all_reviews_count': 'Submit All {count} Reviews',
      'error_display': 'Error: {error}',
      'please_enter_phone': 'Please enter a valid phone number',

      // Start Page
      'welcome': 'Welcome',
      'welcome_to_restaurant': 'Welcome to our Restaurant',
      'admin': 'Admin',
      'customer': 'Customer',
      'user': 'User',
      'select_role': 'Please select your role',

      // Menu Page
      'restaurant_menu': 'Restaurant Menu',
      'main_course': 'Main Course',
      'dessert': 'Dessert',
      'grid_view': 'Grid View',
      'list_view': 'List View',
      'review_selected_items': 'Review Selected Items',
      'no_items_selected': 'Please select at least one item to review',
      'no_items_category': 'No items found in this category',
      'egp': 'EGP',

      // Multi Review Page
      'review_selected_dishes': 'Review Selected Dishes',
      'enter_details': 'Enter Your Details',
      'name': 'Name',
      'phone': 'Phone',
      'enter_name': 'Enter your name',
      'enter_phone': 'Enter your phone number',
      'phone_validation': 'Please enter a valid phone number (11 digits)',
      'name_validation': 'Name is required',
      'rating_validation': 'Please rate all items',
      'rate_dish': 'Rate this dish',
      'add_comment': 'Add your comment here (optional)',

      // Admin Login
      'admin_login': 'Admin Login',
      'username': 'Username',
      'password': 'Password',
      'login': 'Login',
      'invalid_credentials': 'Invalid username or password',

      // Admin Dashboard
      'admin_dashboard': 'Admin Dashboard',
      'menu_reviews': 'Menu Reviews',
      'menu_management': 'Menu Management',
      'reviews_analytics': 'Reviews & Analytics',
      'total_reviews': 'Total Reviews',
      'average_rating': 'Average Rating',
      'total_menu_items': 'Total Menu Items',
      'recent_reviews': 'Recent Reviews',
      'reviewer': 'Reviewer',
      'rating': 'Rating',
      'comment': 'Comment',
      'date': 'Date',
      'no_reviews': 'No reviews available',

      // Success Messages
      'thank_you': 'Thank You!',
      'review_submitted': 'Your review has been submitted successfully!',
      'reviews_submitted': 'Your reviews have been submitted successfully!',
      'back_to_menu': 'Back to Menu',
      'home': 'Home',

      // Error Messages
      'error_loading': 'Failed to load data',
      'error_submitting': 'Failed to submit review',
      'try_again': 'Try Again',

      // Common
      'cancel': 'Cancel',
      'ok': 'OK',
      'price': 'Price',
      'loading': 'Loading...',
      'back': 'Back',
      'next': 'Next',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'search': 'Search',
      'filter': 'Filter',
    },
    'ar': {
      // Common
      'anonymous': 'مجهول',
      'error': 'خطأ',
      'average_rating_colon': 'متوسط التقييم:',
      'user_suggestions': 'اقتراحات المستخدمين (الأقل تقييماً أولاً):',
      'user_suggestions_lowest': 'اقتراحات المستخدمين (الأقل تقييماً أولاً):',
      'sort_by_rating': 'ترتيب حسب التقييم:',
      'highest_to_lowest': 'من الأعلى إلى الأقل',
      'lowest_to_highest': 'من الأقل إلى الأعلى',

      // Review Page
      'rate_each_item': 'قيم كل عنصر (1-5 نجوم)',
      'rate_item': 'قيم هذا العنصر (1-5 نجوم)',
      'rate_overall': 'التقييم العام',
      'write_comment': 'اكتب تعليقك هنا (اختياري)',
      'submit_review': 'إرسال التقييم',
      'submit_reviews': 'إرسال التقييمات',
      'submit_all_reviews': 'إرسال جميع التقييمات',
      'submit_all_reviews_count': 'إرسال جميع {count} التقييمات',
      'error_display': 'خطأ: {error}',
      'please_enter_phone': 'الرجاء إدخال رقم هاتف صحيح',

      // Start Page
      'welcome': 'مرحباً',
      'welcome_to_restaurant': 'مرحباً بك في المطعم',
      'admin': 'مسؤول',
      'customer': 'عميل',
      'user': 'مستخدم',
      'select_role': 'الرجاء اختيار دورك',

      // Menu Page
      'restaurant_menu': 'قائمة المطعم',
      'main_course': 'الطبق الرئيسي',
      'dessert': 'الحلويات',
      'grid_view': 'عرض شبكي',
      'list_view': 'عرض قائمة',
      'review_selected_items': 'مراجعة العناصر المحددة',
      'no_items_selected': 'الرجاء اختيار عنصر واحد على الأقل للمراجعة',
      'no_items_category': 'لا توجد عناصر في هذه الفئة',
      'egp': 'جنيه',

      // Multi Review Page
      'review_selected_dishes': 'مراجعة الأطباق المختارة',
      'enter_details': 'أدخل بياناتك',
      'name': 'الاسم',
      'phone': 'رقم الهاتف',
      'enter_name': 'أدخل اسمك',
      'enter_phone': 'أدخل رقم هاتفك',
      'phone_validation': 'الرجاء إدخال رقم هاتف صحيح (11 رقم)',
      'name_validation': 'الاسم مطلوب',
      'rating_validation': 'الرجاء تقييم جميع العناصر',
      'rate_dish': 'قيم هذا الطبق',
      'add_comment': 'أضف تعليقك هنا (اختياري)',
      'rating_review_mismatch': 'تقييمات الأطباق المختارة لا تتطابق مع التقييم العام.',

      // Admin Login
      'admin_login': 'دخول المسؤول',
      'username': 'اسم المستخدم',
      'password': 'كلمة المرور',
      'login': 'دخول',
      'invalid_credentials': 'اسم المستخدم أو كلمة المرور غير صحيحة',

      // Admin Dashboard
      'admin_dashboard': 'لوحة تحكم المسؤول',
      'menu_reviews': 'مراجعات القائمة',
      'menu_management': 'إدارة القائمة',
      'reviews_analytics': 'تحليل المراجعات',
      'total_reviews': 'إجمالي المراجعات',
      'average_rating': 'متوسط التقييم',
      'total_menu_items': 'إجمالي عناصر القائمة',
      'recent_reviews': 'التقييمات الحديثة',
      'reviewer': 'المراجع',
      'rating': 'التقييم',
      'comment': 'التعليق',
      'date': 'التاريخ',
      'no_reviews': 'لا توجد تقييمات متاحة',

      // Success Messages
      'thank_you': 'شكراً لك!',
      'review_submitted': 'تم إرسال تقييمك بنجاح!',
      'reviews_submitted': 'تم إرسال تقييماتك بنجاح!',
      'back_to_menu': 'العودة للقائمة',
      'home': 'الرئيسية',

      // Error Messages
      'error_loading': 'فشل في تحميل البيانات',
      'error_submitting': 'فشل في إرسال التقييم',
      'try_again': 'حاول مرة أخرى',

      // Common
      'cancel': 'إلغاء',
      'ok': 'موافق',
      'price': 'السعر',
      'loading': 'جاري التحميل...',
      'back': 'رجوع',
      'next': 'التالي',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'search': 'بحث',
      'filter': 'تصفية',
    },
  };
}
