import 'dart:convert';
import 'package:app/providers/auth_provider.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double totalPrice;

  const PaymentScreen({
    Key? key,
    required this.orderId,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _apiService = ApiService();
  // Future จะเก็บข้อมูลรูปภาพ PNG เป็น Uint8List (ชุดของ bytes)
  late Future<Uint8List> _imageBytesFuture;

  @override
  void initState() {
    super.initState();
    _imageBytesFuture = _generateQrCodeBytes();
  }

  /// ฟังก์ชันสำหรับรับ Base64 String ของ "รูป PNG" จาก API
  Future<Uint8List> _generateQrCodeBytes() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token == null) {
        throw Exception('Authentication token not found.');
      }
      
      final token = authProvider.token!;
      
      final response = await _apiService.createPromptPayCharge(
        widget.orderId,
        widget.totalPrice,
        token,
      );
      
      // รับ Key ที่มีข้อมูล PNG Base64
      final base64String = response['qrCodeBase64'];
      if (base64String == null || base64String.isEmpty) {
        throw Exception('API response did not contain qrCodeBase64 data.');
      }

      // แปลง Base64 String กลับเป็นข้อมูลรูปภาพ (Uint8List)
      return base64Decode(base64String);

    } catch (e) {
      // ส่งต่อ Error เพื่อให้ FutureBuilder แสดงผล
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan to Pay'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'สแกนเพื่อชำระเงิน',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'ยอดรวม: ฿${widget.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              
              FutureBuilder<Uint8List>(
                future: _imageBytesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 250,
                      width: 250,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } 
                  else if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 60),
                          const SizedBox(height: 10),
                          Text(
                            'Error: ${snapshot.error}'.replaceAll("Exception: ", ""),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } 
                  else if (snapshot.hasData) {
                    // ใช้ Image.memory เพื่อแสดงผลรูปภาพ PNG จากข้อมูลใน Memory
                    return Image.memory(
                      snapshot.data!,
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                      gaplessPlayback: true, // ทำให้รูปไม่กระพริบตอนโหลดใหม่
                    );
                  }
                  return const Text('Something went wrong.');
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'เมื่อชำระเงินสำเร็จ สถานะคำสั่งซื้อจะอัปเดตอัตโนมัติ',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('กลับสู่หน้าหลัก'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
