import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // *** ข้อควรระวังเรื่อง IP Address ***
  // สำหรับ Android Emulator ใช้ '10.0.2.2'
  // สำหรับ iOS Simulator ใช้ 'localhost'
  // สำหรับอุปกรณ์จริง ให้ใช้ IP Address ของเครื่องคอมพิวเตอร์ในวง LAN เดียวกัน
  static final String _baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:5000'
      : 'http://localhost:5000';

  Future<String> getWelcomeMessage() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Failed to connect to API';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future login(String text, String text2) async {}
}