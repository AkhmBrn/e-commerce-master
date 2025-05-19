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
    };
    
    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Token $token';
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
}
