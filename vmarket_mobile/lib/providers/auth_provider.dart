import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  bool _isEmailVerified = false;
  bool _isLoading = false;

  AuthProvider(this._apiService);

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  bool get isEmailVerified => _isEmailVerified;
  bool get isLoading => _isLoading;

  // Helper method for testing
  void setAuthState(bool isAuthenticated, Map<String, dynamic>? userData) {
    _isAuthenticated = isAuthenticated;
    _user = userData;
    if (userData != null && userData.containsKey('email_verified')) {
      _isEmailVerified = userData['email_verified'] == true;
    }
    notifyListeners();
  }

  Future<void> init() async {
    try {
      final token = await _apiService.getStoredToken();
      _isAuthenticated = token != null;
      if (_isAuthenticated) {
        await refreshUserData();
      }
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _isEmailVerified = false;
    }
  }

  Future<void> refreshUserData() async {
    try {
      if (_isAuthenticated) {
        _setLoading(true);
        final userData = await _apiService.getUserProfile();
        _user = userData;

        // Check if email is verified
        if (userData.containsKey('email_verified')) {
          _isEmailVerified = userData['email_verified'] == true;
        }

        notifyListeners();
      }
    } catch (e) {
      // Failed to fetch user data but might still be authenticated
      print('Error refreshing user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _setLoading(true);
      final response = await _apiService.login(email, password);
      _isAuthenticated = true;
      _user = response['user'];

      // Check if email is verified
      if (_user != null && _user!.containsKey('email_verified')) {
        _isEmailVerified = _user!['email_verified'] == true;
      }

      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _isEmailVerified = false;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup(String email, String password) async {
    try {
      _setLoading(true);
      await _apiService.signup(email, password);
      await login(email, password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      print('AuthProvider: Updating profile with data: $data');
      
      // Make the API call
      final updatedUser = await _apiService.updateProfile(data);
      print('AuthProvider: Profile update response: $updatedUser');
      
      // Merge the updated data with the existing user data
      // This ensures we don't lose fields that weren't updated
      if (_user != null) {
        _user = {..._user!, ...updatedUser};
      } else {
        _user = updatedUser;
      }

      // Check if email is verified
      if (_user!.containsKey('email_verified')) {
        _isEmailVerified = _user!['email_verified'] == true;
      }

      notifyListeners();
      print('AuthProvider: User data updated successfully');
    } catch (e) {
      print('Error in AuthProvider.updateProfile: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      _setLoading(true);
      await _apiService.deleteAccount(password);
      _isAuthenticated = false;
      _user = null;
      _isEmailVerified = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      _setLoading(true);
      await _apiService.sendVerificationEmail();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  Future<bool> verifyEmail(String token) async {
    try {
      _setLoading(true);
      final result = await _apiService.verifyEmail(token);
      // Check if the verification was successful based on the response
      final bool isSuccess = result.containsKey('success') && result['success'] == true;
      if (isSuccess) {
        _isEmailVerified = true;
        if (_user != null) {
          _user!['email_verified'] = true;
        }
        notifyListeners();
      }
      return isSuccess;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      await _apiService.logout();
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      _isAuthenticated = false;
      _user = null;
      _isEmailVerified = false;
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
