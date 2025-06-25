import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. เพิ่ม import provider
import '../models/product_model.dart';
import '../providers/cart_provider.dart'; // 2. เพิ่ม import CartProvider
import '../services/product_service.dart';
import './cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // ดึงข้อมูลสินค้าเมื่อหน้าจอถูกสร้าง
    _productsFuture = _productService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูล username จาก AuthProvider มาแสดง
    final username = Provider.of<AuthProvider>(context, listen: false).username;

    return Scaffold(
      appBar: AppBar(
        title: Text(username != null ? 'Welcome, $username' : 'In-Game Shop'),
        // 3. เพิ่ม actions ให้กับ AppBar
        actions: [
          // ใช้ Consumer เพื่อ rebuild เฉพาะส่วนของไอคอนตะกร้าเมื่อมีการเปลี่ยนแปลง
          Consumer<CartProvider>(
            builder: (ctx, cart, child) => Badge(
              // แสดงจำนวนสินค้าในตะกร้า
              label: Text(cart.itemCount.toString()),
              // ซ่อน Badge ถ้าไม่มีสินค้า
              isLabelVisible: cart.itemCount > 0,
              // child คือ IconButton ที่เราส่งเข้ามา ไม่ต้อง rebuild ทุกครั้ง
              child: child,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                // กดแล้วไปที่หน้าตะกร้าสินค้า
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const CartScreen()),
                );
              },
            ),
          ),
          // เพิ่มปุ่ม Logout เพื่อความสะดวก
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // เรียกใช้ฟังก์ชัน logout จาก AuthProvider
              Provider.of<AuthProvider>(context, listen: false).logout();
              // ไม่ต้องใช้ Navigator เพราะ Consumer ใน main.dart จะสลับหน้าให้เอง
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // แสดง Error message ที่ชัดเจนขึ้น
            return Center(child: Text('Failed to load products: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          } else {
            final products = snapshot.data!;
            // ใช้ RefreshIndicator เพื่อให้ผู้ใช้สามารถดึงข้อมูลใหม่ได้
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _productsFuture = _productService.fetchProducts();
                });
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(product: product);
                },
              ),
            );
          }
        },
      ),
    );
  }
}

// Widget สำหรับการ์ดสินค้า (ไม่มีการแก้ไข)
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'product-image-${product.id}', // เพิ่ม Hero animation
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey));
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
