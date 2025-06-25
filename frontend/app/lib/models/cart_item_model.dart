import './product_model.dart';

class CartItem {
  final String id; // ใช้ ID ของ Product เป็น ID ของ Cart Item
  final String name;
  final String imageUrl;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });
  
  // สร้าง CartItem จาก Product
  factory CartItem.fromProduct(Product product) {
    return CartItem(
      id: product.id,
      name: product.name,
      imageUrl: product.imageUrl,
      price: product.price,
      quantity: 1, // เริ่มต้นที่ 1 ชิ้น
    );
  }
}