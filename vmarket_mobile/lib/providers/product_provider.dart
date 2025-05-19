import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService;
  List<dynamic> _products = [];
  Map<String, dynamic>? _currentProduct;
  bool _isLoading = false;
  String _searchQuery = '';

  ProductProvider(this._apiService);

  List<dynamic> get products => _products;
  Map<String, dynamic>? get currentProduct => _currentProduct;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _products = await _apiService.getProducts();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchProduct(int id) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _currentProduct = await _apiService.getProduct(id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  Future<void> searchProducts(String query) async {
    try {
      _isLoading = true;
      _searchQuery = query;
      notifyListeners();
      
      _products = await _apiService.searchProducts(query);
      
      // Log product data for debugging
      if (kDebugMode) {
        print('Search returned ${_products.length} products');
        if (_products.isNotEmpty) {
          print('First product fields: ${_products.first.keys.join(', ')}');
          print('Image field value: ${_products.first['image'] ?? _products.first['image_url'] ?? _products.first['get_image'] ?? 'No image field found'}');
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearCurrentProduct() {
    _currentProduct = null;
    notifyListeners();
  }

  void clearSearchResults() {
    _products = [];
    _searchQuery = '';
    notifyListeners();
  }
}
