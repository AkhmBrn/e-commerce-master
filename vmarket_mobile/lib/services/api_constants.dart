class ApiConstants {
    static const String baseUrl = 'http://10.0.2.2:8000/api/v1';  // For Android Emulator
  static const String mediaBaseUrl = 'http://10.0.2.2:8000';  // For Android Emulator image URLs  // For Android Emulator
  
  // Auth endpoints
  static const String login = '/token/login/';
  static const String signup = '/users/';
  static const String userDetails = '/users/me/';
  
  // Product endpoints
  static const String products = '/products/';
  static const String categories = '/categories/';
  static const String search = '/products/search/';
  
  // Cart and Order endpoints
  static const String cart = '/cart/';
  static const String orders = '/orders/';
  static const String checkout = '/checkout/';
}
