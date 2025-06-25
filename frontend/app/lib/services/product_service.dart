import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  final String _baseUrl = "http://localhost:5000/api"; // หรือ IP ของเครื่องคุณ

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Product> products = body.map((dynamic item) => Product.fromJson(item)).toList();
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  // เราจะสร้างฟังก์ชัน fetchProductById ทีหลัง
}