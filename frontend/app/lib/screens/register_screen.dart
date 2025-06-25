import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // ตรวจสอบ Path ให้ถูกต้อง

// แก้ไขชื่อ Class ให้ตรงกับชื่อไฟล์
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  // สร้าง Controller แยกสำหรับแต่ละช่อง
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    // ตรวจสอบ validation
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      // เรียกใช้ Provider เพื่อสมัครสมาชิก
      await Provider.of<AuthProvider>(context, listen: false).register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );

      // ถ้าการสมัครสำเร็จ ให้กลับไปหน้าก่อนหน้า (Login) และแสดงข้อความ
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Registration successful! Please log in.'),
          ),
        );
      }
    } catch (error) {
      // ถ้าเกิดข้อผิดพลาด ให้แสดง Dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An Error Occurred!'),
            // ตัดคำว่า "Exception: " ที่ไม่จำเป็นออกไป
            content: Text(error.toString().replaceFirst("Exception: ", "")),
            actions: [
              TextButton(
                child: const Text('Okay'),
                onPressed: () => Navigator.of(ctx).pop(),
              )
            ],
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // *** จุดที่แก้ไข *** ใช้ _usernameController
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // *** จุดที่แก้ไข *** ใช้ _emailController
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit, // เรียกใช้ฟังก์ชัน _submit
                  child: const Text('Register'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}