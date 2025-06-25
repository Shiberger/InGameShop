import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
// import service ของคุณ

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  void _checkout() async {
      final cart = Provider.of<CartProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);

      if (auth.token == null) {
          // ควรจะไปหน้า login แต่โดยปกติจะมาหน้านี้ไม่ได้ถ้ายังไม่ login
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please login first.')));
          return;
      }
      
      setState(() { _isLoading = true; });

      try {
          // *** สร้างฟังก์ชันนี้ใน ApiService ของคุณ ***
          // await ApiService().createOrder(cart.items.values.toList(), auth.token!);
          
          // เมื่อสำเร็จ
          cart.clearCart();
          Navigator.of(context).pop(); // กลับไปหน้า Home
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('Order created successfully!')
              ),
          );

      } catch (e) {
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                  title: const Text('An error occurred!'),
                  content: Text(e.toString()),
                  actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Okay'))],
              ),
          );
      } finally {
          if (mounted) {
              setState(() { _isLoading = false; });
          }
      }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
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
                    itemBuilder: (ctx, i) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(cartItems[i].imageUrl),
                      ),
                      title: Text(cartItems[i].name),
                      subtitle: Text('Total: \$${(cartItems[i].price * cartItems[i].quantity).toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${cartItems[i].quantity} x'),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              cart.removeItem(cartItems[i].id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          if (cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 20)),
                      Chip(
                        label: Text(
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          onPressed: _checkout,
                          child: const Text('CHECKOUT'),
                        )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}