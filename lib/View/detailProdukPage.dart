import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:reuse_mart/entity/produk.dart';
import 'package:reuse_mart/client/produkClient.dart';
import 'package:reuse_mart/View/loginPage.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ProdukClient produkClient = ProdukClient();
  Produk? product;
  bool isLoading = true;
  String? error;
  bool isLoggedIn = false; // Sementara, implementasikan logika login nanti
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final fetchedProduct = await produkClient.fetchProductDetail(widget.productId);
      setState(() {
        product = fetchedProduct;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE5D7C4),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || product == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFE5D7C4),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error ?? 'Produk tidak ditemukan.', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF354024)),
                child: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE5D7C4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5D7C4),
        elevation: 2,
        title: const Text('ReUseMart', style: TextStyle(color: Color(0xFF4C3D19), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF4C3D19)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Back Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Color(0xFF4C3D19)),
                label: const Text('Kembali', style: TextStyle(color: Color(0xFF4C3D19))),
              ),
            ),
            // Product Detail Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Carousel
                  CarouselSlider(
                    options: CarouselOptions(
                      height: screenWidth * 0.8,
                      viewportFraction: 1.0,
                      onPageChanged: (index, _) => setState(() => currentImageIndex = index),
                    ),
                    items: (product!.additionalImages.isNotEmpty ? product!.additionalImages : [product!.mainImage]).map((image) {
                      return Image.network(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/placeholder.jpg',
                          fit: BoxFit.cover,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // Image Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      product!.additionalImages.isNotEmpty ? product!.additionalImages.length : 1,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == currentImageIndex ? const Color(0xFF4C3D19) : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Product Details
                  Text(
                    product!.name,
                    style: TextStyle(
                      color: const Color(0xFF4C3D19),
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.06,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      Icons.star,
                      size: screenWidth * 0.05,
                      color: i < product!.rating ? Colors.yellow[400] : Colors.grey[300],
                    )),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Harga: ${formatCurrency(product!.price)}',
                    style: TextStyle(color: const Color(0xFF4C3D19), fontSize: screenWidth * 0.05),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kategori: ${product!.category}',
                    style: TextStyle(color: const Color(0xFF4C3D19), fontSize: screenWidth * 0.04),
                  ),
                  if (product!.warranty != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Garansi s/d: ${product!.warranty}',
                      style: TextStyle(color: const Color(0xFF4C3D19), fontSize: screenWidth * 0.04),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    product!.description,
                    style: TextStyle(color: const Color(0xFF4C3D19), fontSize: screenWidth * 0.04),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!isLoggedIn) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigasi ke checkout untuk ${product!.id}')));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF354024),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Beli Sekarang'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!isLoggedIn) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produk ${product!.id} ditambahkan ke keranjang!')));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCFB899),
                            foregroundColor: const Color(0xFF4C3D19),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart, size: 16),
                              SizedBox(width: 4),
                              Text('Keranjang'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Footer
            Container(
              width: double.infinity,
              color: const Color(0xFF4C3D19),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('ReUseMart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('Platform jual beli barang bekas berkualitas', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Tentang Kami', style: TextStyle(color: Colors.white))),
                      TextButton(onPressed: () {}, child: const Text('Syarat & Ketentuan', style: TextStyle(color: Colors.white))),
                      TextButton(onPressed: () {}, child: const Text('Kontak', style: TextStyle(color: Colors.white))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('© ${DateTime.now().year} ReUseMart. All rights reserved.', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}