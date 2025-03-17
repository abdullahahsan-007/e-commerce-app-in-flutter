import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add Product
  Future<void> addProduct(Map<String, dynamic> productData) async {
    await _db.collection('products').add(productData);
  }

  // Get Products
  Stream<QuerySnapshot> getProducts() {
    return _db.collection('products').snapshots();
  }

  // Add Order
  Future<void> addOrder(Map<String, dynamic> orderData) async {
    await _db.collection('orders').add(orderData);
  }

  // Get Orders
  Stream<QuerySnapshot> getOrders(String userId) {
    return _db.collection('orders').where('userId', isEqualTo: userId).snapshots();
  }

   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ProductModel>> fetchProducts() async {
    QuerySnapshot snapshot = await _firestore.collection('products').get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }


}
