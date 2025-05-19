import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';
import 'api_exception.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();
  
  Future<String?> getStoredToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Token $token';
      } else {
        print('Warning: No auth token available but requiresAuth is true');
      }
    }
    
    return headers;
  }

  // Auth Methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.login),
      headers: await _getHeaders(requiresAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['auth_token']);
      return data;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.signup),
      headers: await _getHeaders(requiresAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to signup');
    }
  }

  // Product Methods
  Future<List<dynamic>> getProducts() async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.products),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }  Future<Map<String, dynamic>> getProduct(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products/$id/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load product');
    }
  }

  // Cart Methods
  Future<List<dynamic>> getCart() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/cart/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<Map<String, dynamic>> addToCart(int productId, int quantity) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/cart/'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add to cart');
    }
  }

  // Search Method
  Future<List<dynamic>> searchProducts(String query) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/products/search/'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'query': query,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search products');
    }
  }
  
  // Category Methods
  Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.categories),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<dynamic>> getCategoryProducts(int categoryId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categories}$categoryId/products/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load category products');
    }
  }

  // Order Methods
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.orders),
      headers: await _getHeaders(),
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create order');
    }
  }

  Future<List<dynamic>> getOrders() async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.orders),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // User Profile Methods
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.userProfile),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      print('Sending profile update request with data: $data');
      
      final headers = await _getHeaders();
      
      // Send the PATCH request
      final response = await http.patch(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.userProfile),
        headers: headers,
        body: jsonEncode(data),
      );

      print('Profile update response status: ${response.statusCode}');
      print('Profile update response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw ApiException(
          'Failed to update profile: Server returned status ${response.statusCode}',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      print('Exception during profile update: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update profile: ${e.toString()}');
    }
  }

  Future<void> deleteAccount(String password) async {
    final response = await http.delete(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.deleteAccount),
      headers: await _getHeaders(),
      body: jsonEncode({'current_password': password}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete account');
    }
  }

  Future<void> sendVerificationEmail() async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.emailVerification),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send verification email');
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.verifyEmail),
      headers: await _getHeaders(),
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify email');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // Address Methods
  Future<List<dynamic>> getAddresses() async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.addresses),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load addresses');
    }
  }

  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.addresses),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create address');
    }
  }

  Future<Map<String, dynamic>> updateAddress(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addresses}$id/'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update address');
    }
  }

  Future<void> deleteAddress(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addresses}$id/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete address');
    }
  }

  Future<Map<String, dynamic>> setDefaultAddress(int id) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addresses}$id/set_default/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to set default address');
    }
  }

  // Settings Methods
  Future<Map<String, dynamic>> getUserSettings() async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.userSettings),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user settings');
    }
  }

  Future<Map<String, dynamic>> updateUserSettings(Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.userSettings),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user settings');
    }
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.changePassword),
      headers: await _getHeaders(),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to change password');
    }
  }
}
