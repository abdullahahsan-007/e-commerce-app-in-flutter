import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final String status;
  final double total;

  const OrderCard({super.key, 
    required this.orderId,
    required this.status,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: $orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Status: $status', style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 8),
            Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
