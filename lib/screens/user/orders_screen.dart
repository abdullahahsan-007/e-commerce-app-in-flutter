import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  double calculateTotalPrice(List<dynamic> items) {
    double totalPrice = 0.0;
    for (var item in items) {
      double price = double.tryParse(item['price'].toString()) ?? 0.0;  // Ensuring price is a double
      int quantity = item['quantity'] ?? 1;  // Ensuring quantity is an int
      totalPrice += price * quantity;  // Price * Quantity
    }
    return totalPrice;
  }

  int calculateTotalQuantity(List<dynamic> items) {
    int totalQuantity = 0;
    for (var item in items) {
      totalQuantity += (item['quantity'] ?? 0) as int;  // Add up all quantities, ensuring it's an int
    }
    return totalQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.green,  // Updated AppBar color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders available.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final List<dynamic> items = order['items'] ?? [];  // Fetching items from the order
              final double totalPrice = calculateTotalPrice(items);  // Calculating total price
              final int totalQuantity = calculateTotalQuantity(items);  // Calculating total quantity

              return Card(
                elevation: 8,  // Increased elevation for a card shadow effect
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),  // Rounded corners for cards
                  side: const BorderSide(color: Colors.green, width: 2),  // Green border for cards
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  title: Text(
                    'Order ID: ${order['orderId'] ?? 'N/A'}',  // Displaying orderId
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...items.map((item) {
                        // Ensure price and quantity are treated as numeric values
                        double price = double.tryParse(item['price'].toString()) ?? 0.0;
                        int quantity = item['quantity'] ?? 1;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            '${item['name']} - \$${price.toString()} x ${quantity.toString()}',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          'Total Quantity: $totalQuantity',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.shopping_cart,
                    color: Colors.green,
                    size: 30,
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
