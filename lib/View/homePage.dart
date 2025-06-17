import 'package:flutter/material.dart';
import 'package:reuse_mart/entity/produk.dart';
import 'package:reuse_mart/entity/kategori.dart';
import 'package:reuse_mart/client/produkClient.dart';
import 'package:reuse_mart/View/loginPage.dart';
import 'package:reuse_mart/View/merchandisePage.dart';
import 'package:reuse_mart/View/topsellerPage.dart';
import 'package:reuse_mart/View/detailProdukPage.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController tabController;
  final TextEditingController searchController = TextEditingController();
  final ProdukClient produkClient = ProdukClient();

  List<Produk> products = [];
  List<Kategori> categories = [];
  String selectedCategory = 'Semua Kategori';
  bool isLoading = false;
  String? error;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    fetchData();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final fetchedProducts = await produkClient.fetchProducts();
      final fetchedCategories = await produkClient.fetchCategories();
      print('Produk diterima: ${fetchedProducts.length}');
      print('Kategori diterima: ${fetchedCategories.length}');
      setState(() {
        products = fetchedProducts;
        categories = [Kategori(id: 0, name: 'Semua Kategori'), ...fetchedCategories];
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

  void _onSearchChanged() {
    setState(() {});
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFE5D7C4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5D7C4),
        elevation: 2,
        title: const Text(
          'ReUseMart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C3D19),
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Color(0xFF4C3D19), size: 24),
            onPressed: () {
              if (!isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigasi ke keranjang')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF4C3D19), size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          homePageContent(screenWidth, screenHeight),
          const MerchandisePage(),
          const Topsellerpage(),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF354024),
        height: 60,
        child: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.home, size: 28)),
            Tab(icon: Icon(Icons.shopping_bag, size: 28)),
            Tab(icon: Icon(Icons.emoji_events, size: 28)),
          ],
        ),
      ),
    );
  }

  Widget homePageContent(double screenWidth, double screenHeight) {
    final filteredProducts = products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(searchController.text.toLowerCase());
      final matchesCategory = selectedCategory == 'Semua Kategori' || product.category == selectedCategory;
      final isAvailable = product.status_produk == 'tersedia';
      return matchesSearch && matchesCategory && isAvailable;
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: [

          // Banner
          Container(
            margin: const EdgeInsets.all(12),
            height: screenHeight * 0.25,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://i.pinimg.com/736x/21/51/3e/21513e266a55c279054f9f55f0383b86.jpg',
                    height: screenHeight * 0.25,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/placeholder.jpg',
                      height: screenHeight * 0.25,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Selamat datang di ReUseMart! Temukan produk bekas berkualitas untuk gaya hidup berkelanjutan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              height: 1.2,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 9.0),
                child: Text(
                  'Pilih Kategori:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Selamat datang di ReUseMart! Temukan produk bekas berkualitas untuk gaya hidup berkelanjutan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.035,
                            height: 1.2,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search and Category Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: TextStyle(fontSize: screenWidth * 0.04),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF4C3D19), size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4C3D19)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: TextStyle(color: Color(0xFF4C3D19), fontSize: screenWidth * 0.04),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.name,
                        child: Text(
                          category.name,
                          style: TextStyle(fontSize: screenWidth * 0.035),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4C3D19)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                    dropdownColor: const Color(0xFFE5D7C4),
                    style: const TextStyle(color: Color(0xFF4C3D19)),
                  ),
                ),
              ],
            ),
          ),
          // Product Grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!, style: TextStyle(color: Color(0xFF4C3D19), fontSize: screenWidth * 0.04)))
                    : filteredProducts.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada produk tersedia.',
                              style: TextStyle(color: Color(0xFF4C3D19), fontSize: screenWidth * 0.04),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(productId: product.id),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: const Color(0xFF889063),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                              child: Image.network(
                                                product.mainImage,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                                  'assets/placeholder.jpg',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 6,
                                              left: 6,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: product.warranty != null
                                                      ? (product.isWarrantyActive ? const Color(0xFF354024) : Colors.red[600])
                                                      : Colors.grey[600],
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  product.warranty != null
                                                      ? 'Garansi s/d: ${product.warranty} (${product.warrantyStatus})'
                                                      : 'Tanpa Garansi',
                                                  style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: TextStyle(
                                                color: const Color(0xFFE5D7C4),
                                                fontWeight: FontWeight.bold,
                                                fontSize: screenWidth * 0.04,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: List.generate(5, (i) {
                                                return Icon(
                                                  Icons.star,
                                                  size: screenWidth * 0.035,
                                                  color: i < product.rating ? Colors.yellow[400] : Colors.grey[300],
                                                );
                                              }),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Harga: ${formatCurrency(product.price)}',
                                              style: TextStyle(color: const Color(0xFFCFB899), fontSize: screenWidth * 0.035),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (!isLoggedIn) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => const LoginPage()),
                                                      );
                                                      return;
                                                    }
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Produk ${product.id} ditambahkan ke keranjang!')),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFFCFB899),
                                                    foregroundColor: const Color(0xFF4C3D19),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                    minimumSize: Size(screenWidth * 0.18, 0),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.shopping_cart, size: screenWidth * 0.035),
                                                      const SizedBox(width: 4),
                                                      Text('Sale', style: TextStyle(fontSize: screenWidth * 0.03)),
                                                    ],
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (!isLoggedIn) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => const LoginPage()),
                                                      );
                                                      return;
                                                    }
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Navigasi ke checkout untuk ${product.id}')),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF354024),
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                    minimumSize: Size(screenWidth * 0.18, 0),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.shopping_bag, size: screenWidth * 0.035),
                                                      const SizedBox(width: 4),
                                                      Text('Beli', style: TextStyle(fontSize: screenWidth * 0.03)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          ],
        ),
      );
    }
  }
