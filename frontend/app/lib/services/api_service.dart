import 'dart:convert';
import 'dart:io' show Platform;
import 'package:app/models/cart_item_model.dart';
import 'package:app/models/product_model.dart';
import 'package:http/http.dart' as http;

/// ApiService Class
///
/// คลาสสำหรับจัดการการเชื่อมต่อกับ API ทั้งหมดของแอปพลิเคชัน
/// รวมฟังก์ชันสำหรับ Authentication, Products, Orders, และ Payments
class ApiService {

  /// กำหนด Base URL ของ API แบบอัตโนมัติตาม Platform
  String get _baseUrl {
    if (Platform.isAndroid) {
      // สำหรับ Android Emulator, IP 10.0.2.2 จะหมายถึง localhost ของเครื่องคอมพิวเตอร์
      return "http://10.0.2.2:5000/api";
    } else {
      // สำหรับ iOS Simulator และอื่นๆ สามารถใช้ localhost ได้โดยตรง
      return "http://localhost:5000/api";
    }
  }

  // --- Authentication ---

  /// ส่งข้อมูลเพื่อสมัครสมาชิกใหม่
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) { // 201 Created
        // Backend ไม่ได้คืนค่าอะไรกลับมาเมื่อสมัครสำเร็จ
        // เราจึงคืนค่าเป็น Map ว่างๆ เพื่อให้รู้ว่าสำเร็จ
        return {}; 
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to register');
    }
  }

  /// ส่งข้อมูลเพื่อเข้าสู่ระบบ
  /// คืนค่าเป็น Map ที่มี token และข้อมูล user
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to login');
    }
  }


  // --- Products ---

  /// ดึงข้อมูลสินค้าทั้งหมดจาก Server
  Future<List<Product>> fetchProducts() async {
    final url = Uri.parse('$_baseUrl/products');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Product> products = body.map((dynamic item) => Product.fromJson(item)).toList();
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }


  // --- Orders & Payment ---

  /// สร้าง Order ใหม่ในระบบ
  /// รับรายการสินค้าในตะกร้าและ Token ของผู้ใช้
  Future<Map<String, dynamic>> createOrder(List<CartItem> orderItems, String token) async {
    final url = Uri.parse('$_baseUrl/orders');
    
    final List<Map<String, dynamic>> itemsAsJson = orderItems.map((item) => {
      'product': item.id,
      'name': item.name,
      'qty': item.quantity,
      'price': item.price,
      'image': item.imageUrl,
    }).toList();

    final totalPrice = orderItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // ส่ง Token เพื่อยืนยันตัวตน
      },
      body: json.encode({
        'orderItems': itemsAsJson,
        'totalPrice': totalPrice,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to create order');
    }
  }

  /// สร้าง QR Code สำหรับ PromptPay ผ่าน Omise
  /// รับ Order ID, จำนวนเงิน, และ Token
  Future<Map<String, dynamic>> createPromptPayCharge(String orderId, double amount, String token) async {
    final url = Uri.parse('$_baseUrl/payment/promptpay');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'orderId': orderId,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to create charge');
    }
  }
}
