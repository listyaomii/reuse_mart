import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reuse_mart/client/kurirClient.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CourierProfilePage extends StatefulWidget {
  final String token;
  const CourierProfilePage({super.key, required this.token});

  @override
  State<CourierProfilePage> createState() => _CourierProfilePageState();
}

class _CourierProfilePageState extends State<CourierProfilePage> {
  final KurirClient _client = KurirClient();
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> deliveryTasks = [];
  bool _isLoadingProfile = true;
  bool _isLoadingTasks = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchDeliveryHistory();
  }

  Future<void> _fetchProfile() async {
    try {
      setState(() {
        _isLoadingProfile = true;
        _errorMessage = null;
      });
      final profile = await _client.getProfileKurir(widget.token);
      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _fetchDeliveryHistory() async {
    try {
      setState(() {
        _isLoadingTasks = true;
        _errorMessage = null;
      });
      final tasks = await _client.getHistoryPengirimanKurir(widget.token);
      setState(() {
        deliveryTasks = tasks;
        _isLoadingTasks = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingTasks = false;
      });
    }
  }

  Future<void> _updateDeliveryStatus(
      String idPenjualan, String newStatus) async {
    try {
      setState(() {
        _isLoadingTasks = true;
        _errorMessage = null;
      });
      await _client.updateStatus(widget.token, idPenjualan, newStatus);
      await _fetchDeliveryHistory();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingTasks = false;
      });
    }
  }

  String formatRupiah(dynamic value) {
    final doubleVal = double.tryParse(value.toString()) ?? 0.0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ')
        .format(doubleVal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFBB99),
      appBar: AppBar(
        backgroundColor: const Color(0xFF354024),
        title: const Text(
          'ReuseMart - Profil Kurir',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {},
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.settings, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: _isLoadingProfile || _isLoadingTasks
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileSection(),
                      const SizedBox(height: 24),
                      _buildDeliveryHistorySection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileSection() {
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
                  _profile?['nama_pegawai'] ?? 'Rudi Kurir',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF354024),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _profile?['email_pegawai'] ?? 'rudi.kurir@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Saldo: ${_profile?['saldo_pegawai'] != null ? formatRupiah(_profile!['saldo_pegawai']) : 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Tugas Pengiriman',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF354024),
          ),
        ),
        const SizedBox(height: 12),
        deliveryTasks.isEmpty
            ? const Center(
                child: Text(
                  'Tidak ada riwayat pengiriman.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: deliveryTasks.length,
                itemBuilder: (context, index) {
                  final task = deliveryTasks[index];

                  String produkList = 'N/A';
                  if (task['detail_penjualan'] is List) {
                    produkList = (task['detail_penjualan'] as List).map((item) {
                      final produk = item['produk'];
                      if (produk is Map && produk['nama_produk'] != null) {
                        return produk['nama_produk'];
                      }
                      return 'Produk tidak tersedia';
                    }).join(', ');
                  }

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        'Tugas #${task['id_penjualan']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF354024),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pembeli: ${task['pembeli']?['nama_pembeli'] ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Item: $produkList',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Tujuan: ${task['alamat']?['alamat'] ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Total Harga: ${formatRupiah(task['total_harga'])}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Ongkir: ${formatRupiah(task['ongkir'])}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Tanggal: ${task['tanggal_pesan'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(task['tanggal_pesan'])) : 'N/A'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Status Pembayaran: ${task['status_pembayaran'] ?? 'N/A'}',
                            style: TextStyle(
                              color: task['status_pembayaran'] == 'valid'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Status: ${task['status_penjualan']}',
                            style: TextStyle(
                              color: task['status_penjualan'] == 'selesai'
                                  ? Colors.green
                                  : task['status_penjualan'] == 'dikirim'
                                      ? Colors.orange
                                      : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed:
                                (task['status_penjualan'] == 'Dijadwalkan' ||
                                        task['status_penjualan'] ==
                                            'siap dikirim' ||
                                        task['status_penjualan'] == 'Disiapkan')
                                    ? () {
                                        _updateDeliveryStatus(
                                            task['id_penjualan'].toString(),
                                            'dikirim');
                                      }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF354024),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Kirim'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: task['status_penjualan'] == 'dikirim'
                                ? () {
                                    _updateDeliveryStatus(
                                        task['id_penjualan'].toString(),
                                        'selesai');
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF354024),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Selesai'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
