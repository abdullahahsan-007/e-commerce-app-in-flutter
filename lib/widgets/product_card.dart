import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;

  const ProductCard({super.key, required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.network(imageUrl, height: 100),
          Text(name),
        ],
      ),
    );
  }
}
