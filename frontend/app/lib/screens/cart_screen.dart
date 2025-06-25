import 'package:app/models/cart_item_model.dart';
import 'package:app/screens/payment_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;
  // สร้าง Instance ของ ApiService เพื่อให้เรียกใช้งานได้
  final ApiService _apiService = ApiService();

  /// ฟังก์ชันสำหรับจัดการการ Checkout
  Future<void> _checkout() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // ตรวจสอบว่าผู้ใช้ Login อยู่หรือไม่
    if (!auth.isAuth || auth.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to proceed.')),
      );
      return;
    }

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }
    
    setState(() { _isLoading = true; });

    try {
      final createdOrder = await _apiService.createOrder(
        cart.items.values.toList(),
        auth.token!,
      );

      cart.clearCart();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => PaymentScreen(
              orderId: createdOrder['_id'], 
              totalPrice: (createdOrder['totalPrice'] as num).toDouble(),
            ),
          ),
        );
      }

    } catch (e) {
      // --- จุดแก้ไข ---
      // สร้างข้อความ Error ที่เข้าใจง่ายขึ้น
      String errorMessage = e.toString().replaceFirst("Exception: ", "");
      
      // ตรวจจับข้อผิดพลาดประเภท HTML โดยเฉพาะ
      if (errorMessage.contains("FormatException") && errorMessage.toLowerCase().contains("html")) {
        errorMessage = "เกิดข้อผิดพลาดฝั่ง Server (Backend)\n\nแอปได้รับข้อมูลกลับมาเป็น HTML แทนที่จะเป็น JSON ที่คาดไว้ กรุณาตรวจสอบ Log ใน Terminal ของ Backend เพื่อหาข้อผิดพลาดที่แท้จริง";
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An Error Occurred!'),
            content: Text(errorMessage), // แสดงข้อความที่ปรับปรุงแล้ว
            actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Okay'))],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final cartItems = cart.items.values.toList();
        return Scaffold(
          appBar: AppBar(title: const Text('Your Cart')),
          body: Column(
            children: [
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text('Your cart is empty.'))
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (ctx, i) => CartItemWidget(cartItem: cartItems[i]),
                      ),
              ),
              if (cartItems.isNotEmpty)
                CheckoutCard(
                  totalAmount: cart.totalAmount,
                  isLoading: _isLoading,
                  onCheckout: _checkout,
                ),
            ],
          ),
        );
      },
    );
  }
}

// --- Widgets ---

class CheckoutCard extends StatelessWidget {
  final double totalAmount;
  final bool isLoading;
  final VoidCallback onCheckout;

  const CheckoutCard({
    Key? key,
    required this.totalAmount,
    required this.isLoading,
    required this.onCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(fontSize: 20)),
            const Spacer(),
            Chip(
              label: Text(
                '฿${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 10),
            if (isLoading)
              const CircularProgressIndicator()
            else
              TextButton(
                onPressed: onCheckout,
                child: const Text('CHECKOUT'),
              ),
          ],
        ),
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({Key? key, required this.cartItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(cartItem.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<CartProvider>(context, listen: false).removeItem(cartItem.id);
      },
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(Icons.delete, color: Colors.white, size: 40),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(cartItem.imageUrl),
            ),
            title: Text(cartItem.name),
            subtitle: Text('Total: ฿${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}'),
            trailing: Text('${cartItem.quantity} x'),
          ),
        ),
      ),
    );
  }
}
