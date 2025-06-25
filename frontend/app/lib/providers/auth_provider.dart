import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final _secureStorage = const FlutterSecureStorage();

  String? _token;
  String? _userId;
  String? _username;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    // สามารถเพิ่ม logic ตรวจสอบวันหมดอายุของ token ที่นี่ได้ในอนาคต
    return _token;
  }

  String? get userId {
    return _userId;
  }

  String? get username {
    return _username;
  }

  Future<void> register(String username, String email, String password) async {
    await _authService.register(username, email, password);
    // หลังสมัครสำเร็จ อาจจะให้ login อัตโนมัติ หรือกลับไปหน้า login ก็ได้
    // ในที่นี้ เราจะให้กลับไปหน้า login ก่อน
  }

  Future<void> login(String email, String password) async {
    try {
      final responseData = await _authService.login(email, password);
      _token = responseData['token'];
      _userId = responseData['userId'];
      _username = responseData['username'];

      // เก็บ token และ user info ลงใน secure storage
      await _secureStorage.write(key: 'token', value: _token);
      await _secureStorage.write(key: 'userId', value: _userId);
      await _secureStorage.write(key: 'username', value: _username);
      
      notifyListeners(); // แจ้งเตือน UI ให้ update
    } catch (error) {
      // ส่ง error ต่อไปให้ UI แสดงผล
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _username = null;
    
    // ลบข้อมูลออกจาก storage
    await _secureStorage.deleteAll();
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final token = await _secureStorage.read(key: 'token');
    if (token == null) {
      return false; // ไม่มี token, ไม่ต้อง auto login
    }

    // มี token, ตั้งค่า state และแจ้ง UI
    _token = token;
    _userId = await _secureStorage.read(key: 'userId');
    _username = await _secureStorage.read(key: 'username');
    notifyListeners();
    return true;
  }
}