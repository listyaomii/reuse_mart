import 'package:flutter/material.dart';
import 'package:reuse_mart/View/loginPage.dart';
import 'package:reuse_mart/View/merchandisePage.dart';
import 'package:reuse_mart/View/topsellerPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> allItems = [
    {'name': 'Meja bekas', 'category': 'Perabot'},
    {'name': 'Kursi plastik', 'category': 'Perabot'},
    {'name': 'TV second', 'category': 'Elektronik'},
    {'name': 'Baju Vintage', 'category': 'Fashion'},
    {'name': 'Kompor Gas', 'category': 'Elektronik'},
    {'name': 'Rak Kayu', 'category': 'Perabot'},
  ];
  List<Map<String, String>> filteredItems = [];

  List<String> categories = [
    'Semua Kategori',
    'Elektronik',
    'Fashion',
    'Perabot'
  ];
  String selectedCategory = 'Semua Kategori';

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);

    filteredItems = allItems.where((item) {
      return item['category'] == 'Fashion';
    }).toList();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      filteredItems = allItems.where((item) {
        final matchesSearch = item['name']!
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        final matchesCategory = selectedCategory == 'Semua Kategori' ||
            item['category'] == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFBB99),
      appBar: AppBar(
        backgroundColor: const Color(0xFF354024),
        title: const Text(
          'ReuseMart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          homePageContent(),
          const merchandisePage(),
          const Topsellerpage(),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF354024),
        height: 75,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.home, size: 35)),
              Tab(icon: Icon(Icons.shopping_bag, size: 35)),
              Tab(icon: Icon(Icons.emoji_events, size: 35)),
            ],
          ),
        ),
      ),
    );
  }

  Widget homePageContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Cari barang...',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/benner_welcome.jpg',
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
              ),
              DropdownButton<String>(
                value: selectedCategory,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                    _onSearchChanged();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // supaya gak konflik scroll
            itemCount: filteredItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 2,
            ),
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag,
                          size: 40, color: Color(0xFF354024)),
                      const SizedBox(height: 8),
                      Text(
                        item['name']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
