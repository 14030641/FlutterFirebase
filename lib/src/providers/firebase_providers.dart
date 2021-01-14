import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practica5/src/models/product_dao.dart';

class FirebaseProvider {
  FirebaseFirestore _firestore;
  CollectionReference _productCollection;
  FirebaseProvider() {
    _firestore = FirebaseFirestore.instance;
    _productCollection = _firestore.collection('products');
  }

  Future<void> saveProduct(ProductDAO product) {
    return _productCollection.add(product.toMap());
  }

  Future<void> updateProduct(ProductDAO product, String documentID) {
    return _productCollection.doc(documentID).update(product.toMap());
  }

  Future<void> deleteProduct(String documentID) {
    return _productCollection.doc(documentID).delete();
  }

  Stream<QuerySnapshot> getAllProducts() {
    return _productCollection.snapshots();
  }
}
