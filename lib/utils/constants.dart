// lib/utils/constants.dart

/// Supabase table name constants
class Tables {
  static const String profiles   = 'profiles';
  static const String categories = 'categories';
  static const String products   = 'products';
  static const String cartItems  = 'cart_items';
  static const String orders     = 'orders';
  static const String orderItems = 'order_items';
}

/// User type identifiers
class UserTypes {
  static const int admin = 1;
  static const int user  = 2;

  static String getLabel(int type) {
    switch (type) {
      case admin: return 'Admin';
      case user:  return 'Customer';
      default:    return 'User';
    }
  }
}

/// Supabase Storage bucket constants
class StorageBuckets {
  static const String productImages = 'product-images';
}

/// App-wide text / string constants
class AppText {
  static const String appName        = 'Grocery App';
  static const String currencySymbol = '₨';
  static const String currency       = 'PKR';
}