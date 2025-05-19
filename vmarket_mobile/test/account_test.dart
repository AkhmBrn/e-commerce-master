import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:vmarket_mobile/providers/auth_provider.dart';
import 'package:vmarket_mobile/services/api_service.dart';
import 'package:vmarket_mobile/models/address.dart';
import 'package:vmarket_mobile/models/order.dart';

@GenerateMocks([ApiService])
import 'account_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late AuthProvider authProvider;

  setUp(() {
    mockApiService = MockApiService();
    authProvider = AuthProvider(mockApiService);
  });

  group('AuthProvider', () {
    test('initial state is unauthenticated with no user data', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
      expect(authProvider.isEmailVerified, false);
      expect(authProvider.isLoading, false);
    });

    test('login updates authentication state and user data', () async {
      final userData = {
        'user': {
          'id': 1,
          'name': 'Test User',
          'email': 'test@example.com',
          'phone': '1234567890',
          'email_verified': true,
        }
      };

      when(mockApiService.login('test@example.com', 'password123'))
          .thenAnswer((_) async => userData);

      await authProvider.login('test@example.com', 'password123');

      expect(authProvider.isAuthenticated, true);
      expect(authProvider.user, userData['user']);
      expect(authProvider.isEmailVerified, true);
    });

    test('logout clears authentication state and user data', () async {
      // Set up authenticated state first
      authProvider = AuthProvider(mockApiService)
        ..setAuthState(true, {'id': 1, 'name': 'Test User', 'email_verified': true});

      when(mockApiService.logout()).thenAnswer((_) async => {});

      await authProvider.logout();

      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
      expect(authProvider.isEmailVerified, false);
    });

    test('refreshUserData updates user data and email verification status', () async {
      // Set up authenticated state first
      authProvider = AuthProvider(mockApiService)..setAuthState(true, null);

      final profileData = {
        'id': 1,
        'name': 'Updated Name',
        'email': 'test@example.com',
        'email_verified': true,
      };

      when(mockApiService.getUserProfile())
          .thenAnswer((_) async => profileData);

      await authProvider.refreshUserData();

      expect(authProvider.user, profileData);
      expect(authProvider.isEmailVerified, true);
    });

    test('updateProfile updates user data and email verification status', () async {
      // Set up authenticated state first
      authProvider = AuthProvider(mockApiService)
        ..setAuthState(true, {'id': 1, 'name': 'Test User', 'email_verified': false});

      final updatedData = {
        'id': 1,
        'name': 'Updated Name',
        'email': 'test@example.com',
        'phone': '9876543210',
        'email_verified': true,
      };

      when(mockApiService.updateProfile({
        'name': 'Updated Name',
        'phone': '9876543210',
      })).thenAnswer((_) async => updatedData);

      await authProvider.updateProfile({
        'name': 'Updated Name',
        'phone': '9876543210',
      });

      expect(authProvider.user, updatedData);
      expect(authProvider.isEmailVerified, true);
    });
    
    test('deleteAccount clears auth state when successful', () async {
      // Set up authenticated state first
      authProvider = AuthProvider(mockApiService)
        ..setAuthState(true, {'id': 1, 'name': 'Test User'});

      when(mockApiService.deleteAccount('password123'))
          .thenAnswer((_) async => {});
          
      await authProvider.deleteAccount('password123');
      
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
      expect(authProvider.isEmailVerified, false);
    });
    
    test('verifyEmail updates verification status when successful', () async {
      // Set up authenticated state with unverified email
      authProvider = AuthProvider(mockApiService)
        ..setAuthState(true, {'id': 1, 'name': 'Test User', 'email_verified': false});

      when(mockApiService.verifyEmail('valid-token'))
          .thenAnswer((_) async => true);
          
      final result = await authProvider.verifyEmail('valid-token');
      
      expect(result, true);
      expect(authProvider.isEmailVerified, true);
      expect(authProvider.user?['email_verified'], true);
    });
    
    test('sendVerificationEmail calls api service', () async {
      when(mockApiService.sendVerificationEmail())
          .thenAnswer((_) async => {});
          
      await authProvider.sendVerificationEmail();
      
      verify(mockApiService.sendVerificationEmail()).called(1);
    });
  });

  group('Address Model', () {
    test('creates Address from JSON', () {
      final json = {
        'id': 1,
        'name': 'Home',
        'address_line1': '123 Main St',
        'address_line2': 'Apt 4B',
        'city': 'New York',
        'state': 'NY',
        'zip_code': '10001',
        'phone': '1234567890',
        'is_default': true,
      };

      final address = Address.fromJson(json);

      expect(address.id, 1);
      expect(address.name, 'Home');
      expect(address.addressLine1, '123 Main St');
      expect(address.addressLine2, 'Apt 4B');
      expect(address.city, 'New York');
      expect(address.state, 'NY');
      expect(address.zipCode, '10001');
      expect(address.phone, '1234567890');
      expect(address.isDefault, true);
    });

    test('converts Address to JSON', () {
      final address = Address(
        id: 1,
        name: 'Home',
        addressLine1: '123 Main St',
        addressLine2: 'Apt 4B',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        phone: '1234567890',
        isDefault: true,
      );

      final json = address.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Home');
      expect(json['address_line1'], '123 Main St');
      expect(json['address_line2'], 'Apt 4B');
      expect(json['city'], 'New York');
      expect(json['state'], 'NY');
      expect(json['zip_code'], '10001');
      expect(json['phone'], '1234567890');
      expect(json['is_default'], true);
    });

    test('formats address correctly', () {
      final address = Address(
        id: 1,
        name: 'Home',
        addressLine1: '123 Main St',
        addressLine2: 'Apt 4B',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        phone: '1234567890',
        isDefault: true,
      );

      expect(address.formattedAddress, '123 Main St\nApt 4B\nNew York, NY 10001');
    });
  });

  group('Order Model', () {
    test('creates Order from JSON', () {
      final json = {
        'id': 1,
        'status': 'processing',
        'created_at': '2025-05-18T10:30:00Z',
        'subtotal': '100.00',
        'tax': '8.00',
        'shipping_cost': '10.00',
        'total': '118.00',
        'payment_method': 'Credit Card',
        'shipping_address': '123 Main St, New York, NY 10001',
        'items': [
          {
            'id': 1,
            'quantity': 2,
            'product': {
              'id': 101,
              'name': 'Test Product',
              'price': '50.00',
              'image_url': 'https://example.com/image.jpg',
            },
          },
        ],
      };

      final order = Order.fromJson(json);

      expect(order.id, 1);
      expect(order.status, 'processing');
      expect(order.createdAt.toIso8601String(), '2025-05-18T10:30:00.000Z');
      expect(order.subtotal, 100.0);
      expect(order.tax, 8.0);
      expect(order.shippingCost, 10.0);
      expect(order.total, 118.0);
      expect(order.paymentMethod, 'Credit Card');
      expect(order.shippingAddress, '123 Main St, New York, NY 10001');
      expect(order.items.length, 1);
      expect(order.items[0].id, 1);
      expect(order.items[0].quantity, 2);
      expect(order.items[0].product.id, 101);
      expect(order.items[0].product.name, 'Test Product');
      expect(order.items[0].product.price, 50.0);
      expect(order.items[0].product.imageUrl, 'https://example.com/image.jpg');
    });
  });
}
