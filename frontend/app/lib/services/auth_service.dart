import 'dart:convert';
import 'dart:io' show Platform; // 1. import dart:io
import 'package:http/http.dart' as http;

class AuthService {

  // 2. สร้างฟังก์ชันเพื่อเลือก Base URL อัตโนมัติ
  String _getBaseUrl() {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5000/api/auth";
    } else { // iOS และอื่นๆ
      return "http://localhost:5000/api/auth";
    }
  }

  Future<void> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('${_getBaseUrl()}/register'), // 3. เรียกใช้ฟังก์ชัน
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to register');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${_getBaseUrl()}/login'), // 3. เรียกใช้ฟังก์ชัน
      headers: {'Content-Type': 'application/json'},
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
}