import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'orders_screen.dart';
import 'search_screen.dart';
import 'about_screen.dart';
import 'cart_screen.dart';
import '../auth/signin_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  // Cart items list
  final List<Map<String, dynamic>> _cart = [];

  // Pass the `_cart` list to each screen
  List<Widget> get _widgetOptions => [
        UserHomeScreen(
          addToCart: _addToCart, // Pass the addToCart function
        ),
        const OrderScreen(),
        SearchScreen(
          addToCart: _addToCart, // Pass the addToCart function
        ),
        ProfileScreen(),
      ];

  // Add product to cart
  void _addToCart(Map<String, dynamic> product) {
    final existingProductIndex =
        _cart.indexWhere((item) => item['name'] == product['name']);

    if (existingProductIndex >= 0) {
      setState(() {
        _cart[existingProductIndex]['quantity'] += 1;
      });
    } else {
      setState(() {
        _cart.add({...product, 'quantity': 1});
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to cart!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Switch tabs
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce App'),
        backgroundColor: Colors.green[800],  // Dark green AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _selectedIndex = 2; // Navigate to SearchScreen
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(cartItems: _cart),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.green[50],  // Light green background for the drawer
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,  // Green color for the header
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'E-Commerce App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Welcome to our store',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.green),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag, color: Colors.green),
                title: const Text('My Orders'),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.green),
                title: const Text('About Us'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.green),
                title: const Text('Logout'),
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                 
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,  // Green for selected items
        unselectedItemColor: Colors.grey,  // Grey for unselected items
        backgroundColor: Colors.white,  // White background
        elevation: 12,  // Slightly raised bottom navigation bar
      ),
    );
  }
}
