import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import ini untuk inisialisasi locale
import 'package:reuse_mart/client/NotificationService.dart';
import 'package:reuse_mart/client/pembeliClient.dart';
import 'package:reuse_mart/client/TransaksiPenjualanClient.dart';
import 'package:reuse_mart/entity/pembeli.dart' as pembeli_entity;
import 'package:reuse_mart/entity/TransaksiPenjualan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reuse_mart/View/detailProduk.dart';
import 'package:reuse_mart/services/auth_service.dart';
import 'dart:convert';

class Pembelihome extends StatefulWidget {
  const Pembelihome({super.key});

  @override
  State<Pembelihome> createState() => _PembelihomeState();
}

class _PembelihomeState extends State<Pembelihome> {
  final NotificationService _notificationService = NotificationService();

  // Data profil pembeli
  Pembeli? pembeli;
  bool isLoadingProfile = true; // Cek apakah profil sedang dimuat
  String? errorMessage; // Pesan error jika ada masalah

  // Data pesanan
  String activeTab = 'pesanan'; // Tab yang aktif
  String? activeOrderTab; // Status pesanan yang dipilih
  List<TransaksiPenjualan> belumDibayar = [];
  List<TransaksiPenjualan> dikemas = [];
  List<TransaksiPenjualan> dikirim = [];
  List<TransaksiPenjualan> diterima = [];
  List<TransaksiPenjualan> dibatalkan = [];
  bool isLoadingOrders = true; // Cek apakah pesanan sedang dimuat

  // Token untuk autentikasi
  String? token;

  @override
  void initState() {
    super.initState();
    _initializeLocale(); // Atur format tanggal lokal
    _notificationService.initialize(context);
    _notificationService.checkInitialMessage(context);
    _loadTokenAndFetchData();
  }

  // Atur format tanggal lokal
  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return 'Rp 0';
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Logout pengguna
  Future<void> _logout() async {
    await AuthService.logout(context);
  }

  // Ambil data profil
  Future<void> _fetchProfile() async {
    try {
      print(
          'Fetching profile with token: ${token?.substring(0, 20) ?? 'null'}...');
      if (token == null || token!.isEmpty) {
        throw Exception('Token tidak tersedia');
      }
      bool isTokenValid = await PembeliClient.validateToken(token!);
      if (!isTokenValid) {
        throw Exception('Token tidak valid atau sudah expired');
      }
      final response = await PembeliClient.showMobile(token!);
      final jsonData = json.decode(response.body);
      Map<String, dynamic> profileData;
      if (jsonData is Map<String, dynamic>) {
        if (jsonData.containsKey('data')) {
          profileData = jsonData['data'];
        } else {
          profileData = jsonData;
        }
      } else {
        throw Exception('Format response tidak valid');
      }
      setState(() {
        pembeli = Pembeli.fromJson(profileData);
        isLoadingProfile = false;
      });
      print('Profile loaded successfully: ${pembeli?.namaPembeli}');
    } catch (e) {
      print('Error in _fetchProfile: $e');
      setState(() {
        errorMessage = 'Gagal memuat profil: $e';
        isLoadingProfile = false;
      });
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized') ||
          e.toString().contains('Token tidak valid')) {
        _handleAuthenticationError();
      }
    }
  }

  Future<void> _handleAuthenticationError() async {
    await AuthService.handleAuthError(context, 'Authentication failed');
  }

  Future<void> _loadTokenAndFetchData() async {
    try {
      await AuthService.debugSessionInfo();
      final sessionData = await AuthService.getSessionData();
      token = sessionData['token'];
      final role = sessionData['role'];
      print(
          'Loading data for Pembeli - Token: ${token?.substring(0, 20) ?? 'null'}..., Role: $role');
      if (token != null && token!.isNotEmpty) {
        if (role != 'pembeli') {
          print('Role mismatch! Expected: pembeli, Got: $role');
          await AuthService.handleAuthError(
              context, 'Role tidak sesuai untuk halaman pembeli');
          return;
        }
        await Future.wait([
          _fetchProfile(),
          _fetchOrders(),
        ]);
      } else {
        setState(() {
          errorMessage = 'Pengguna belum terautentikasi. Silakan login.';
          isLoadingProfile = false;
          isLoadingOrders = false;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      }
    } catch (e) {
      print('Error in _loadTokenAndFetchData: $e');
      setState(() {
        errorMessage = 'Gagal memuat data: $e';
        isLoadingProfile = false;
        isLoadingOrders = false;
      });
    }
  }

  Future<void> _fetchOrders() async {
    try {
      print('Fetching orders with token: ${token?.substring(0, 20)}...');
      if (token == null || token!.isEmpty) {
        throw Exception('Token tidak tersedia');
      }
      final orders = await TransaksiPenjualanClient.fetchAll(token!);
      setState(() {
        belumDibayar = orders
            .where((order) => order.statusPembayaran == 'belum_dibayar')
            .toList();
        dikemas = orders
            .where((order) => order.statusPenjualan == 'dikemas')
            .toList();
        dikirim = orders
            .where((order) => order.statusPenjualan == 'dikirim')
            .toList();
        diterima = orders
            .where((order) => order.statusPenjualan == 'diterima')
            .toList();
        dibatalkan = orders
            .where((order) => order.statusPenjualan == 'dibatalkan')
            .toList();
        isLoadingOrders = false;
      });
      print('Orders loaded successfully - Total: ${orders.length}');
    } catch (e) {
      print('Error in _fetchOrders: $e');
      setState(() {
        errorMessage = 'Gagal memuat pesanan: $e';
        isLoadingOrders = false;
      });
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized') ||
          e.toString().contains('Token tidak valid')) {
        _handleAuthenticationError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5D7C4), // Latar belakang beige
      appBar: AppBar(
        backgroundColor: const Color(0xFF4C3D19), // Warna header hijau tua
        title: const Text('Profil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _logout, // Tombol logout
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _buildMainContent(), // Konten utama dipisah untuk kemudahan
    );
  }

  // Bangun konten utama halaman
  Widget _buildMainContent() {
    if (isLoadingProfile || isLoadingOrders) {
      return const Center(
          child: CircularProgressIndicator(
              color: Color(0xFF4C3D19))); // Loading indicator
    } else if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!,
                style: const TextStyle(
                    color: Color(0xFF4C3D19))), // Tampilkan error
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTokenAndFetchData, // Tombol coba lagi
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(), // Bagian profil
            _buildTabSection(), // Bagian tab pesanan
            if (activeTab == 'pesanan')
              _buildPesananSection(), // Bagian daftar pesanan
          ],
        ),
      );
    }
  }

  // Bangun bagian profil
  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.all(16), // Jarak luar
      padding: const EdgeInsets.all(16), // Jarak dalam
      decoration: BoxDecoration(
        color: Colors.white, // Latar putih
        borderRadius: BorderRadius.circular(12), // Sudut melengkung
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF4C3D19), // Warna avatar
            backgroundImage: pembeli?.fotoProfilPembeli != null
                ? NetworkImage(pembeli!.fotoProfilPembeli!)
                : null,
            child: pembeli?.fotoProfilPembeli == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pembeli?.namaPembeli ?? 'N/A',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C3D19))),
                Text(pembeli?.email ?? 'N/A',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFF4C3D19), size: 20),
                    const SizedBox(width: 4),
                    Text('Poin: ${pembeli?.poinPembeli ?? 0}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C3D19))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bangun bagian tab
  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  activeTab = 'pesanan';
                  activeOrderTab = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: activeTab == 'pesanan'
                          ? const Color(0xFF4C3D19)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  'Pesanan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: activeTab == 'pesanan'
                        ? const Color(0xFF4C3D19)
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bangun bagian pesanan
  Widget _buildPesananSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatusPesananIcons(), // Ikon status pesanan
          const SizedBox(height: 20),
          if (activeOrderTab != null) _buildListPesanan(), // Daftar pesanan
        ],
      ),
    );
  }

  // Bangun ikon status pesanan
  Widget _buildStatusPesananIcons() {
    List<Map<String, dynamic>> statusList = [
      {
        'icon': Icons.access_time,
        'title': 'Belum\nDibayar',
        'status': 'belum_dibayar',
        'count': belumDibayar.length
      },
      {
        'icon': Icons.inventory,
        'title': 'Dikemas',
        'status': 'dikemas',
        'count': dikemas.length
      },
      {
        'icon': Icons.local_shipping,
        'title': 'Dikirim',
        'status': 'dikirim',
        'count': dikirim.length
      },
      {
        'icon': Icons.check_circle,
        'title': 'Diterima',
        'status': 'diterima',
        'count': diterima.length
      },
      {
        'icon': Icons.cancel,
        'title': 'Dibatalkan',
        'status': 'dibatalkan',
        'count': dibatalkan.length
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: statusList.map((status) {
        bool isActive = activeOrderTab == status['status'];
        return GestureDetector(
          onTap: () {
            setState(() {
              activeOrderTab = isActive ? null : status['status'];
            });
          },
          child: Column(
            children: [
              Stack(
                children: [
                  Icon(
                    status['icon'] as IconData, // Pastikan ikon
                    size: 30,
                    color: isActive ? const Color(0xFF4C3D19) : Colors.grey,
                  ),
                  if (status['count'] > 0)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${status['count']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                status['title'] as String, // Pastikan teks
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? const Color(0xFF4C3D19) : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Bangun daftar pesanan
  Widget _buildListPesanan() {
    List<TransaksiPenjualan> orders = [];
    String title = '';

    switch (activeOrderTab) {
      case 'belum_dibayar':
        orders = belumDibayar;
        title = 'Pesanan Belum Dibayar';
        break;
      case 'dikemas':
        orders = dikemas;
        title = 'Pesanan Dikemas';
        break;
      case 'dikirim':
        orders = dikirim;
        title = 'Pesanan Dikirim';
        break;
      case 'diterima':
        orders = diterima;
        title = 'Pesanan Diterima';
        break;
      case 'dibatalkan':
        orders = dibatalkan;
        title = 'Pesanan Dibatalkan';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C3D19),
          ),
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Tidak ada pesanan',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order);
            },
          ),
      ],
    );
  }

  // Format tanggal dengan aman
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Bangun kartu pesanan
  Widget _buildOrderCard(TransaksiPenjualan order) {
    final detail = order.detailPenjualan?.isNotEmpty == true
        ? order.detailPenjualan![0]
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailProdukPage(transaksi: order),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail?.produk?.namaProduk ?? 'Produk',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(detail?.produk?.harga),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(order.tanggalPesan),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
