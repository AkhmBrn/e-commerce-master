class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8800/api/v1';  // For Android Emulator
  static const String mediaBaseUrl = 'http://10.0.2.2:8800';  // For Android Emulator image URLs
  
  // Auth endpoints
  static const String login = '/token/login/';
  static const String signup = '/users/';
  static const String userDetails = '/users/me/';
  static const String changePassword = '/users/set_password/';
  
  // User Profile & Account
  static const String userProfile = '/users/me/';
  static const String addresses = '/addresses/';
  static const String userSettings = '/users/settings/';
  static const String deleteAccount = '/account/delete/';
  static const String emailVerification = '/email-verification/';
  static const String verifyEmail = '/email-verification/verify/';
  
  // Product endpoints
  static const String products = '/products/';
  static const String categories = '/categories/';
  static const String search = '/products/search/';
  
  // Cart and Order endpoints
  static const String cart = '/cart/';
  static const String orders = '/orders/';
  static const String checkout = '/checkout/';
}
