import 'dart:convert';
import 'dart:io' show Platform;
import 'package:app/models/cart_item_model.dart';
import 'package:app/models/product_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  String get _baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5000/api";
    } else {
      return "http://localhost:5000/api";
    }
  }

  // ... (โค้ด login, register, fetchProducts ของคุณ) ...
  // --- Start of existing code ---
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
    if (response.statusCode == 201) {
        return {}; 
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to register');
    }
  }
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
  // --- End of existing code ---

  Future<Map<String, dynamic>> createOrder(List<CartItem> orderItems, String token) async {
    final url = Uri.parse('$_baseUrl/orders');
    final List<Map<String, dynamic>> itemsAsJson = orderItems.map((item) => {
      'product': item.id, 'name': item.name, 'qty': item.quantity, 'price': item.price, 'image': item.imageUrl,
    }).toList();
    final totalPrice = orderItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'Bearer $token'},
      body: json.encode({'orderItems': itemsAsJson, 'totalPrice': totalPrice}),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to create order');
    }
  }

  Future<Map<String, dynamic>> createPromptPayCharge(String orderId, double amount, String token) async {
    final url = Uri.parse('$_baseUrl/payment/promptpay');
    
    try {
      print('[Debug Log] Step 4: ApiService is calling http.post to ${url.toString()}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'Bearer $token'},
        body: json.encode({'orderId': orderId, 'amount': amount}),
      ).timeout(const Duration(seconds: 30)); // เพิ่ม Timeout ป้องกันการค้าง

      print('[Debug Log] Step 5: ApiService received a response. Status: ${response.statusCode}');
      // print('[Debug Log] Response Body: ${response.body}'); // เปิดเพื่อดูข้อมูลดิบ

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create charge');
      }
    } catch (e) {
      print('[Debug Log] ❌ ERROR inside ApiService.createPromptPayCharge: ${e.toString()}');
      rethrow; // ส่งต่อ error ให้ที่เรียกใช้จัดการ
    }
  }
}
