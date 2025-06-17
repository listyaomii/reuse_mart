import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reuse_mart/client/komisiClient.dart';
import 'package:reuse_mart/entity/komisi.dart';

// Warna konstanta untuk konsistensi UI
const Color primaryColor = Color(0xFF354024);
const Color backgroundColor = Color(0xFFCFBB99);
const Color cardColor = Colors.white;
const Color errorColor = Colors.red;
const Color textColor = Color(0xFF354024);
const Color subtitleColor = Colors.grey;

class KomisiPage extends StatefulWidget {
  final String idPegawai;
  const KomisiPage({super.key, required this.idPegawai});

  @override
  State<KomisiPage> createState() => _KomisiPageState();
}

class _KomisiPageState extends State<KomisiPage> {
  final KomisiClient _komisiClient = KomisiClient(baseUrl: 'http://192.168.35.56:8000');
  List<Komisi> _komisiList = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchKomisi();
  }

  /// Mengambil data komisi berdasarkan id_pegawai dari server
  Future<void> _fetchKomisi() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final komisiList = await _komisiClient.getKomisiByPegawai(widget.idPegawai);
      setState(() {
        _komisiList = komisiList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat riwayat komisi: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Riwayat Komisi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: errorColor, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildCommissionHistorySection(context),
                ),
    );
  }

  /// Membangun daftar riwayat komisi
  Widget _buildCommissionHistorySection(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Komisi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            GestureDetector(
              onTap: _fetchKomisi,
              child: const Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _komisiList.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada komisi',
                  style: TextStyle(fontSize: 16, color: subtitleColor),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _komisiList.length,
                itemBuilder: (context, index) {
                  final commission = _formatCommission(_komisiList[index], currencyFormat);
                  return Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        commission['nama_produk'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      subtitle: Text(
                        'Penjualan #${commission['id_penjualan']} | Komisi: ${currencyFormat.format(commission['komisi_hunter'])}',
                        style: const TextStyle(color: subtitleColor),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: textColor,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommissionDetailPage(
                              commission: commission,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }

  /// Mengformat data komisi untuk UI
  Map<String, dynamic> _formatCommission(Komisi komisi, NumberFormat currencyFormat) {
    return {
      'nama_produk': komisi.namaProduk,
      'id_penjualan': komisi.idPenjualan.toString(),
      'harga_jual': komisi.hargaJual,
      'komisi_hunter': komisi.komisiHunter,
      'tanggal_bayar': komisi.tanggalBayar != 'Tidak tersedia'
          ? DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(komisi.tanggalBayar))
          : 'Tidak tersedia',
      'nama_penitip': komisi.namaPenitip,
    };
  }
}

/// Halaman untuk menampilkan detail komisi
class CommissionDetailPage extends StatelessWidget {
  final Map<String, dynamic> commission;

  const CommissionDetailPage({super.key, required this.commission});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Detail Komisi #${commission['id_penjualan']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
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
                    commission['nama_produk'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Penjualan #${commission['id_penjualan']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Harga Jual: ${currencyFormat.format(commission['harga_jual'])}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Komisi Hunter: ${currencyFormat.format(commission['komisi_hunter'])}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tanggal Penjualan: ${commission['tanggal_bayar']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Penitip: ${commission['nama_penitip']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}