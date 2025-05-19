import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final ApiService _apiService;
  List<dynamic>? _cartItems;
  bool _isLoading = false;

  CartProvider(this._apiService);
  List<dynamic>? get cartItems => _cartItems;
  bool get isLoading => _isLoading;  double get total {
    if (_cartItems == null) return 0.0;
    return _cartItems!.fold<double>(0.0, (sum, item) {
      final price = double.parse(item['price'].toString());
      final quantity = int.parse(item['quantity'].toString());
      return sum + (price * quantity);
    });
  }

  Future<void> fetchCart() async {
    try {
      _isLoading = true;
      notifyListeners();
        _cartItems = await _apiService.getCart();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addToCart(int productId, int quantity) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _apiService.addToCart(productId, quantity);
      await fetchCart(); // Refresh cart after adding item
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  void clear() {
    _cartItems = null;
    notifyListeners();
  }
}
