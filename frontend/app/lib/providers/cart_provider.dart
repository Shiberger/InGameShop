import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // ถ้ามีสินค้าในตะกร้าแล้ว, ให้เพิ่มจำนวน
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          imageUrl: existingCartItem.imageUrl,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // ถ้ายังไม่มี, ให้เพิ่มเข้าไปใหม่
      _items.putIfAbsent(
        product.id,
        () => CartItem.fromProduct(product),
      );
    }
    // แจ้งให้ Widget ที่กำลังฟังอยู่ Rebuild ตัวเอง
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}