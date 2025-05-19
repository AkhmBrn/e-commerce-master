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
}
