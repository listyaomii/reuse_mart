import 'package:flutter/material.dart';

class HunterProfilePage extends StatelessWidget {
  const HunterProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFBB99), // Warna background krem kecokelatan
      appBar: AppBar(
        backgroundColor: const Color(0xFF354024), // Hijau tua
        title: const Text(
          'ReuseMart - Profil Hunter',
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
                // Aksi untuk logout atau pengaturan profil
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.settings, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Profil dan Jumlah Komisi
            _buildProfileSection(),
            const SizedBox(height: 24),
            // Bagian History Komisi
            _buildCommissionHistorySection(context),
          ],
        ),
      ),
    );
  }

  // Widget untuk bagian profil dan jumlah komisi
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
                const Text(
                  'Alex Hunter', // Nama hunter (bisa diganti dengan data dinamis)
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF354024),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'alex.hunter@example.com', // Email hunter
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
                      'Komisi: Rp500,000', // Jumlah komisi (bisa diganti dengan data dinamis)
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

  // Widget untuk bagian history komisi
  Widget _buildCommissionHistorySection(BuildContext context) {
    // Data dummy untuk history komisi
    final List<Map<String, dynamic>> commissions = [
      {
        'id': 'COM001',
        'date': '28 Mei 2025',
        'amount': 150000,
        'source': 'Penjualan Meja Bekas',
        'details': [
          {'item': 'Meja Bekas', 'price': 100000, 'commission_rate': 0.15},
          {'item': 'Kursi Plastik', 'price': 50000, 'commission_rate': 0.10},
        ],
      },
      {
        'id': 'COM002',
        'date': '27 Mei 2025',
        'amount': 200000,
        'source': 'Penjualan TV Second',
        'details': [
          {'item': 'TV Second', 'price': 200000, 'commission_rate': 0.10},
        ],
      },
    ];

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
                color: Color(0xFF354024),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigasi ke halaman semua komisi (opsional)
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: commissions.length,
          itemBuilder: (context, index) {
            final commission = commissions[index];
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
                  'Komisi #${commission['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF354024),
                  ),
                ),
                subtitle: Text(
                  'Tanggal: ${commission['date']} | Jumlah: Rp${commission['amount']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF354024),
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
}

// Halaman untuk detail komisi
class CommissionDetailPage extends StatelessWidget {
  final Map<String, dynamic> commission;

  const CommissionDetailPage({super.key, required this.commission});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFBB99),
      appBar: AppBar(
        backgroundColor: const Color(0xFF354024),
        title: Text(
          'Detail Komisi #${commission['id']}',
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
            // Informasi Umum Komisi
            Container(
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
                    'Komisi #${commission['id']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF354024),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tanggal: ${commission['date']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sumber: ${commission['source']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jumlah Komisi: Rp${commission['amount']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF354024),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Detail Item yang Menghasilkan Komisi
            const Text(
              'Detail Komisi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF354024),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (commission['details'] as List).length,
              itemBuilder: (context, index) {
                final detail = commission['details'][index];
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
                      detail['item'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF354024),
                      ),
                    ),
                    subtitle: Text(
                      'Harga: Rp${detail['price']} | Komisi: ${(detail['commission_rate'] * 100).toStringAsFixed(0)}% (Rp${(detail['price'] * detail['commission_rate']).toInt()})',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    leading: const Icon(
                      Icons.monetization_on,
                      color: Color(0xFF354024),
                      size: 30,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}