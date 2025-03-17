import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class SearchScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) addToCart;

  const SearchScreen({super.key, required this.addToCart});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  // Search for products based on the query
  void _searchProducts() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      // Query the Firestore collection for products where the name contains the search query
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();

      setState(() {
        _searchResults = snapshot.docs;
      });
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        backgroundColor: Colors.green,  // Updated AppBar color
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Product Name',
                hintText: 'Enter product name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => _searchProducts(),
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      var product = _searchResults[index];
                      String imageUrl = product['imageUrl'] ?? '';
                      String name = product['name'] ?? 'No name available';
                      String description =
                          product['description'] ?? 'No description available';
                      String price = product['price'].toString();

                      return Card(
                        elevation: 6,  // Added elevation for shadow effect
                        margin: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),  // Rounded corners for cards
                          side: const BorderSide(color: Colors.green, width: 1),  // Green border around cards
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: imageUrl.isNotEmpty
                              ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Placeholder(
                                        fallbackHeight: 60, fallbackWidth: 60);
                                  })
                              : const Placeholder(fallbackHeight: 60, fallbackWidth: 60),
                          title: Text(
                            name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Price: \$$price',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            color: Colors.green,
                            onPressed: () {
                              widget.addToCart({
                                'id': product.id,
                                'name': name,
                                'description': description,
                                'price': price,
                                'quantity': 1,
                                'imageUrl': imageUrl,
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
