import 'package:flutter/material.dart';
import 'package:reuse_mart/client/NotificationService.dart';

class Pembelihome extends StatefulWidget {
  const Pembelihome({super.key});

  @override
  State<Pembelihome> createState() => _PembelihomeState();
}

class _PembelihomeState extends State<Pembelihome> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Initialize notification service
    _notificationService.initialize(context);
    _notificationService.checkInitialMessage(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFBB99),
      appBar: AppBar(
        backgroundColor: const Color(0xFF354024),
        title: const Text(
          'ReuseMart - Pembeli',
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
                // Aksi untuk logout atau ke halaman pengaturan profil
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
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
            _buildProfileSection(),
            const SizedBox(height: 24),
            _buildTransactionHistorySection(context),
          ],
        ),
      ),
    );
  }

  // Widget untuk bagian profil dan poin reward
  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Warna card putih
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
                  'John Doe', // Nama pembeli (bisa diganti dengan data dinamis)
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF354024),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'john.doe@example.com', // Email pembeli
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Color(0xFF354024),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Poin Reward: 150', // Poin reward (bisa diganti dengan data dinamis)
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

  // Widget untuk bagian history transaksi
  Widget _buildTransactionHistorySection(BuildContext context) {
    // Data dummy untuk history transaksi
    final List<Map<String, dynamic>> transactions = [
      {
        'id': 'TRX001',
        'date': '28 Mei 2025',
        'total': 150000,
        'items': [
          {'name': 'Meja Bekas', 'price': 100000, 'quantity': 1},
          {'name': 'Kursi Plastik', 'price': 50000, 'quantity': 1},
        ],
      },
      {
        'id': 'TRX002',
        'date': '27 Mei 2025',
        'total': 200000,
        'items': [
          {'name': 'TV Second', 'price': 200000, 'quantity': 1},
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
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF354024),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigasi ke halaman semua transaksi (opsional)
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
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
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
                  'Transaksi #${transaction['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF354024),
                  ),
                ),
                subtitle: Text(
                  'Tanggal: ${transaction['date']} | Total: Rp${transaction['total']}',
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
                      builder: (context) => TransactionDetailPage(
                        transaction: transaction,
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

// Halaman untuk detail transaksi
class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFBB99),
      appBar: AppBar(
        backgroundColor: const Color(0xFF354024),
        title: Text(
          'Detail Transaksi #${transaction['id']}',
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
            // Informasi Umum Transaksi
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
                    'Transaksi #${transaction['id']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF354024),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tanggal: ${transaction['date']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: Rp${transaction['total']}',
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
            // Daftar Item dalam Transaksi
            const Text(
              'Item yang Dibeli',
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
              itemCount: (transaction['items'] as List).length,
              itemBuilder: (context, index) {
                final item = transaction['items'][index];
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
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF354024),
                      ),
                    ),
                    subtitle: Text(
                      'Harga: Rp${item['price']} | Jumlah: ${item['quantity']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    leading: const Icon(
                      Icons.shopping_bag,
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
