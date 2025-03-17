import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  ManageProductsScreenState createState() => ManageProductsScreenState();
}

class ManageProductsScreenState extends State<ManageProductsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Function to add a new product
  void addProduct() {
    final String name = nameController.text;
    final String price = priceController.text;
    final String imageUrl = imageUrlController.text;
    final String description = descriptionController.text;

    if (name.isNotEmpty && price.isNotEmpty && imageUrl.isNotEmpty && description.isNotEmpty) {
      firestore.collection('products').add({
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'description': description,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added!'), backgroundColor: Colors.green),
        );
        _clearTextFields();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.red),
      );
    }
  }

  // Function to edit a product
  void _editProduct(String productId) {
    final String name = nameController.text;
    final String price = priceController.text;
    final String imageUrl = imageUrlController.text;
    final String description = descriptionController.text;

    if (name.isNotEmpty && price.isNotEmpty && imageUrl.isNotEmpty && description.isNotEmpty) {
      firestore.collection('products').doc(productId).update({
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'description': description,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated!'), backgroundColor: Colors.blue),
        );
        _clearTextFields();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.red),
      );
    }
  }

  // Function to delete a product
  void deleteProduct(String productId) {
    firestore.collection('products').doc(productId).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted!'), backgroundColor: Colors.orange),
      );
    });
  }

  // Function to clear text fields
  void _clearTextFields() {
    nameController.clear();
    priceController.clear();
    imageUrlController.clear();
    descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 15,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple, Colors.pinkAccent],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Product Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'Image URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Product Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: addProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                    ),
                    child: const Text(
                      'Add Product',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // List of products from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final products = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final productId = product.id;
                      final name = product['name'];
                      final price = product['price'];
                      final imageUrl = product['imageUrl'];
                      final description = product['description'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('\$${price.toString()}', style: const TextStyle(fontSize: 16)),
                          leading: imageUrl.isNotEmpty
                              ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                              : const Icon(Icons.image, size: 60),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  nameController.text = name;
                                  priceController.text = price;
                                  imageUrlController.text = imageUrl;
                                  descriptionController.text = description;
                                  _editProduct(productId);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteProduct(productId),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
