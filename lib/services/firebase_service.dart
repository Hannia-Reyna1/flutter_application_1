import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class FirebaseService {
  final CollectionReference<Map<String, dynamic>> _products =
      FirebaseFirestore.instance.collection('products');

  // ✅ Agregar un producto con manejo de errores
  Future<void> addProduct(String name, double price, String imageUrl) async {
    try {
      await _products.add({
        'nombre': name,
        'precio': price,
        'imagen': imageUrl,
      });
      log("✅ Producto agregado correctamente");
    } catch (e) {
      log("❌ Error al agregar producto: $e");
    }
  }

  // ✅ Eliminar un producto con manejo de errores
  Future<void> deleteProduct(String id) async {
    try {
      await _products.doc(id).delete();
      log("✅ Producto eliminado correctamente");
    } catch (e) {
      log("❌ Error al eliminar producto: $e");
    }
  }

  // ✅ Obtener la lista de productos
  Stream<QuerySnapshot<Map<String, dynamic>>> getProducts() {
    return _products.snapshots();
  }

  // ✅ Actualizar un producto
  Future<void> updateProduct(String id, String name, double price, String imageUrl) async {
    try {
      await _products.doc(id).update({
        'nombre': name,
        'precio': price,
        'imagen': imageUrl,
      });
      log("✅ Producto actualizado correctamente");
    } catch (e) {
      log("❌ Error al actualizar producto: $e");
    }
  }
}