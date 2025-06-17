import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reuse_mart/entity/TransaksiPenjualan.dart';

class DetailProdukPage extends StatelessWidget {
  final TransaksiPenjualan transaksi;

  const DetailProdukPage({super.key, required this.transaksi});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Belum tersedia';
    try {
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return 'Rp 0';
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'belum_dibayar':
        return 'Belum Dibayar';
      case 'dikemas':
        return 'Dikemas';
      case 'dikirim':
        return 'Dikirim';
      case 'diterima':
        return 'Diterima';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'belum_dibayar':
        return Colors.orange;
      case 'dikemas':
        return Colors.blue;
      case 'dikirim':
        return Colors.purple;
      case 'diterima':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = transaksi.detailPenjualan?.isNotEmpty == true
        ? transaksi.detailPenjualan![0]
        : null;
    final produk = detail?.produk;

    return Scaffold(
      backgroundColor: const Color(0xFFE5D7C4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4C3D19),
        title: const Text(
          'Detail Produk',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Informasi Produk
            _buildInfoCard(
              title: 'Informasi Produk',
              icon: Icons.shopping_bag,
              child: Column(
                children: [
                  _buildInfoRow('Nama Produk', produk?.namaProduk ?? '-'),
                  _buildInfoRow('Berat Produk', '${produk?.berat ?? 0} gram'),
                  _buildInfoRow('Harga Produk', _formatCurrency(produk?.harga)),
                  _buildInfoRow('Rating Produk', '${produk?.rating ?? 0}/5 ⭐'),
                  _buildStatusRow(
                      'Status Pesanan',
                      _getStatusText(transaksi.statusPenjualan ??
                          transaksi.statusPembayaran),
                      _getStatusColor(transaksi.statusPenjualan ??
                          transaksi.statusPembayaran)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Gambar Produk
            _buildInfoCard(
              title: 'Gambar Produk',
              icon: Icons.image,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informasi Alamat Penerima
            if (transaksi.alamat != null)
              _buildInfoCard(
                title: 'Informasi Alamat Penerima',
                icon: Icons.location_on,
                child: Column(
                  children: [
                    _buildInfoRow(
                        'Alamat Lengkap', transaksi.alamat!.alamat ?? '-'),
                    _buildInfoRow(
                        'Kelurahan', transaksi.alamat!.kelurahan ?? '-'),
                    _buildInfoRow(
                        'Kecamatan', transaksi.alamat!.kecamatan ?? '-'),
                    _buildInfoRow('Kode Pos', transaksi.alamat!.kodePos ?? '-'),
                    _buildInfoRow(
                        'Nomor Telepon', transaksi.alamat!.noTelp ?? '-'),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Detail Transaksi
            _buildInfoCard(
              title: 'Detail Transaksi',
              icon: Icons.receipt,
              child: Column(
                children: [
                  _buildInfoRow(
                      'Tanggal Pesan', _formatDate(transaksi.tanggalPesan)),
                  _buildInfoRow(
                      'Tanggal Bayar', _formatDate(transaksi.tanggalBayar)),
                  _buildInfoRow(
                      'Tanggal Ambil', _formatDate(transaksi.tanggalAmbil)),
                  _buildInfoRow(
                      'Jenis Pengambilan',
                      transaksi.jenisPengambilan == 'diantar'
                          ? 'Pengiriman'
                          : 'Ambil Sendiri'),
                  _buildInfoRow(
                      'Ongkos Kirim', _formatCurrency(transaksi.ongkir)),
                  _buildInfoRow(
                      'Poin Ditukar', '${transaksi.poinDitukar} poin'),
                  _buildInfoRow('Hadiah Poin', '${transaksi.poinDidapat} poin'),
                  const Divider(thickness: 1, color: Colors.grey),
                  _buildInfoRow(
                      'Harga Total', _formatCurrency(transaksi.totalHarga),
                      isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF4C3D19),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C3D19),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 14 : 12,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? const Color(0xFF4C3D19) : Colors.grey[600],
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 12)),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 14 : 12,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? const Color(0xFF4C3D19) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 12)),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
