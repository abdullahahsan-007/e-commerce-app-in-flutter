import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import 'product_details_screen.dart'; // Import the details screen

class UserHomeScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) addToCart;

  const UserHomeScreen({super.key, required this.addToCart});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.green, // Updated AppBar color to green
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          final products = snapshot.data!.docs;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final imageUrl = product['imageUrl'] ?? '';
              final name = product['name'] ?? 'No name';
              final description = product['description'] ?? 'No description';
              final price = product['price'] ?? '0.00';

              return GestureDetector(
                onTap: () {
                  // Navigate to the product details screen when a card is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(product: {
                        'imageUrl': imageUrl,
                        'name': name,
                        'description': description,
                        'price': price,
                      }),
                    ),
                  );
                },
                child: Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for card
                    side: const BorderSide(
                      color: Colors.green, // Green border color
                      width: 2, // Border width
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Placeholder(fallbackHeight: 100, fallbackWidth: 100),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green, // Green text for product name
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          description,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '\$${(double.tryParse(price.toString()) ?? 0.0).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final productDetails = {
                            'imageUrl': imageUrl,
                            'name': name,
                            'description': description,
                            'price': price,
                          };
                          addToCart(productDetails);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Set button color to green
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Rounded corners for button
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
