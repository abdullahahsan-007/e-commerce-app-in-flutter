import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure FirebaseAuth is enabled

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double getTotalPrice() {
    return widget.cartItems.fold(0.0, (sum, item) {
      double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
      int quantity = item['quantity'] ?? 1;
      return sum + (price * quantity);
    });
  }

  int getTotalQuantity() {
    return widget.cartItems.fold(0, (sum, item) {
      return sum + (item['quantity'] ?? 1) as int;
    });
  }

  String generateOrderId() {
    return DateTime.now().millisecondsSinceEpoch.toString(); // Unique timestamp-based ID
  }

  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
  }

  void _incrementQuantity(int index) {
    setState(() {
      widget.cartItems[index]['quantity'] += 1;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (widget.cartItems[index]['quantity'] > 1) {
        widget.cartItems[index]['quantity'] -= 1;
      } else {
        widget.cartItems.removeAt(index);
      }
    });
  }

  Future<void> _confirmOrder() async {
    if (widget.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty. Add items before confirming order.')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    double totalPrice = getTotalPrice();
    String orderId = generateOrderId();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _firestore.collection('orders').add({
        'orderId': orderId,
        'items': widget.cartItems,
        'totalPrice': totalPrice,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order Confirmed!')),
      );
      setState(() {
        widget.cartItems.clear();
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OrderSuccessScreen(orderId: orderId)),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm order: $error')),
      );
    } finally {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.green,
      ),
      body: widget.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Shop Now'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      final itemName = item['name'] ?? 'Unnamed Product';
                      final itemPrice = item['price'] ?? '0';
                      final itemQuantity = item['quantity'] ?? 1;

                      return Card(
                        margin: const EdgeInsets.all(8),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: item['imageUrl'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['imageUrl'],
                                    width: 50,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image_not_supported, size: 50);
                                    },
                                  ),
                                )
                              : const Icon(Icons.image, size: 50, color: Colors.green),
                          title: Text(
                            itemName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price: \$$itemPrice'),
                              Text('Quantity: $itemQuantity'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.green),
                                onPressed: () => _decrementQuantity(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.green),
                                onPressed: () => _incrementQuantity(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Quantity: ${getTotalQuantity()}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total Price: \$${getTotalPrice().toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _confirmOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Confirm Order'),
                  ),
                ),
              ],
            ),
    );
  }
}

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Success'), backgroundColor: Colors.green),
      body: Center(
        child: Text(
          'Your order #$orderId has been confirmed!',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
