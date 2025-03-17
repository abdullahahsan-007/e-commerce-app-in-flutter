class OrderModel {
  final String id;
  final String userId;
  final List<String> products;
  final double totalAmount;
  final String status;

  OrderModel({
    required this.id,
    required this.userId,
    required this.products,
    required this.totalAmount,
    required this.status,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      products: List<String>.from(map['products'] ?? []),
      totalAmount: map['totalAmount'] ?? 0.0,
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'products': products,
      'totalAmount': totalAmount,
      'status': status,
    };
  }
}
