import 'package:flutter/material.dart';
import 'package:reuse_mart/entity/penitip.dart';
import 'package:reuse_mart/entity/TransaksiPenitipan.dart';
import 'package:reuse_mart/client/PenitipClient.dart';
import 'package:reuse_mart/services/auth_service.dart';

class SellerProfilePage extends StatefulWidget {
  final String? token;

  const SellerProfilePage({super.key, this.token});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  Penitip? penitip;
  List<TransaksiPenitipan> riwayatPenitipan = [];
  bool isLoading = true;
  String errorMessage = '';
  String? currentToken;

  @override
  void initState() {
    super.initState();
    _validateSessionAndLoadData();
  }

  Future<void> _validateSessionAndLoadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final sessionData = await AuthService.getSessionData();
      final role = sessionData['role'];
      final tokenFromPrefs = sessionData['token'];

      // Validasi role sesuai dengan halaman
      if (role != 'penitip') {
        await AuthService.handleAuthError(
            context, 'Role tidak sesuai untuk halaman penitip');
        return;
      }

      // Flexible token handling - prioritas token dari preferences
      String? workingToken;

      if (tokenFromPrefs != null && tokenFromPrefs.isNotEmpty) {
        workingToken = tokenFromPrefs;
      } else if (widget.token != null && widget.token!.isNotEmpty) {
        workingToken = widget.token;
      } else {
        await AuthService.handleAuthError(context, 'Token tidak ditemukan');
        return;
      }

      setState(() {
        currentToken = workingToken;
      });

      await _loadData();
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal validasi session: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    if (currentToken == null) {
      setState(() {
        errorMessage = 'Token tidak tersedia';
        isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        final profileFuture = PenitipClient.getProfile(currentToken!);
        final riwayatFuture = PenitipClient.getRiwayatPenitipan(currentToken!);

        final results = await Future.wait([profileFuture, riwayatFuture]);

        setState(() {
          penitip = results[0] as Penitip;
          riwayatPenitipan = results[1] as List<TransaksiPenitipan>;
          isLoading = false;
        });
      } catch (clientError) {
        // Handle different types of errors
        if (clientError.toString().contains('401') ||
            clientError.toString().contains('Unauthorized') ||
            clientError.toString().contains('Token tidak valid')) {
          await AuthService.handleAuthError(context, 'Session expired');
          return;
        }

        setState(() {
          errorMessage = 'Gagal memuat data: ${clientError.toString()}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error umum: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFBB99),
      appBar: AppBar(
        backgroundColor: const Color(0xFF354024),
        title: const Text(
          'ReuseMart - Profil Penitip',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _logout,
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data penitip...'),
                ],
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: $errorMessage',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _validateSessionAndLoadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF354024),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileSection(),
                        const SizedBox(height: 24),
                        _buildItemHistorySection(context),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileSection() {
    if (penitip == null) return const SizedBox();

    return Container(
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
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF354024),
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  penitip!.namaPenitip,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF354024),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  penitip!.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFF354024),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Saldo: Rp${penitip!.saldoPenitip.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Color(0xFF354024),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Poin Reward: ${penitip!.poinPenitip}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemHistorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Barang Dititipkan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF354024),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigasi ke halaman semua history
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF354024),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        riwayatPenitipan.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Belum ada riwayat penitipan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    riwayatPenitipan.length > 3 ? 3 : riwayatPenitipan.length,
                itemBuilder: (context, index) {
                  final transaksi = riwayatPenitipan[index];
                  return _buildTransaksiCard(transaksi, context);
                },
              ),
      ],
    );
  }

  Widget _buildTransaksiCard(
      TransaksiPenitipan transaksi, BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          'Penitipan ${transaksi.idPenitipan}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF354024),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal: ${transaksi.tanggalTitip ?? "Tidak ada"}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Total Produk: ${transaksi.details.length}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        children: transaksi.details.map((detail) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              detail.produk['nama_produk'] ?? 'Produk Tidak Diketahui',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kategori: ${detail.produk['kategori'] ?? "Tidak ada"}'),
                Text('Harga: Rp${detail.produk['harga_jual'] ?? 0}'),
                Text(
                    'Status: ${detail.produk['status_produk'] ?? "Tidak ada"}'),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF354024),
              size: 16,
            ),
            onTap: () {
              // Navigasi ke halaman detail produk
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailProdukPenitip(
                    produk: detail.produk,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

// Halaman Detail Produk Sederhana
class DetailProdukPenitip extends StatelessWidget {
  final Map<String, dynamic> produk;

  const DetailProdukPenitip({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFBB99),
      appBar: AppBar(
        backgroundColor: const Color(0xFF354024),
        title: const Text(
          'Detail Produk',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card untuk gambar produk
            Container(
              width: double.infinity,
              height: 200,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: produk['foto'] != null && produk['foto'].isNotEmpty
                    ? Image.network(
                        produk['foto'][0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Card untuk informasi produk
            Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk['nama_produk'] ?? 'Nama Produk Tidak Tersedia',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF354024),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kode Produk: ${produk['kode_produk'] ?? 'Tidak ada'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Kategori', produk['kategori'] ?? 'Tidak ada'),
                  _buildInfoRow('Harga Jual', 'Rp${produk['harga_jual'] ?? 0}'),
                  _buildInfoRow(
                      'Status', produk['status_produk'] ?? 'Tidak ada'),
                  _buildInfoRow('Berat', '${produk['berat'] ?? 0} gram'),
                  _buildInfoRow(
                      'Tanggal Masuk', produk['tanggal_masuk'] ?? 'Tidak ada'),
                  _buildInfoRow(
                      'Batas Ambil', produk['batas_ambil'] ?? 'Tidak ada'),
                  if (produk['deskripsi'] != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Deskripsi:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF354024),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      produk['deskripsi'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF354024),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
