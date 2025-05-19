import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;

  AuthProvider(this._apiService);

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;

  Future<void> init() async {
    try {
      final token = await _apiService.getStoredToken();
      _isAuthenticated = token != null;
      if (_isAuthenticated) {
        // Optionally fetch user data here if needed
      }
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      _isAuthenticated = true;
      _user = response['user'];
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    try {
      await _apiService.signup(email, password);
      await login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
