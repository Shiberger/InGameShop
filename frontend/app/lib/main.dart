import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth_provider.dart';
import './providers/cart_provider.dart';
import './screens/home_screen.dart';
import './screens/login_screen.dart';
import './screens/splash_screen.dart'; // เราจะสร้างไฟล์นี้

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        // เพิ่ม Provider อื่นๆ ที่นี่
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'In-Game Shop',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: auth.isAuth
              ? const HomeScreen() // ถ้าล็อกอินแล้ว ไปหน้า Home
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState == ConnectionState.waiting
                          ? const SplashScreen() // ระหว่างรอ auto-login แสดง Splash
                          : const LoginScreen(), // ถ้าไม่สำเร็จ ไปหน้า Login
                ),
        ),
      ),
    );
  }
}
