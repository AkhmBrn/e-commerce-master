import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/cart_page.dart';
import 'pages/category_page.dart';
import 'pages/checkout_page.dart';
import 'pages/product_page.dart';
import 'pages/search_page.dart';
import 'pages/my_account_page.dart';
import 'pages/about_page.dart';
import 'pages/success_page.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final apiService = ApiService();
  final authProvider = AuthProvider(apiService);
  await authProvider.init();
  
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiService),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => CartProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return MaterialApp(
          title: 'VMarket',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          initialRoute: auth.isAuthenticated ? '/' : '/login',
          routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/cart': (context) => const CartPage(),
        '/category': (context) => const CategoryPage(),
        '/checkout': (context) => const CheckoutPage(),
        '/product': (context) => const ProductPage(),
        '/search': (context) => const SearchPage(),
        '/account': (context) => const MyAccountPage(),
        '/about': (context) => const AboutPage(),
        '/success': (context) => const SuccessPage(),          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to VMarket',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
