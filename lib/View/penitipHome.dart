import 'package:flutter/material.dart';

class SellerProfilePage extends StatelessWidget {
  const SellerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFBB99), // Warna background krem kecokelatan
      appBar: AppBar(
        backgroundColor: const Color(0xFF354024), // Hijau tua
        title: const Text(
          'ReuseMart - Profil Penitip',
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
            // Bagian Profil, Saldo, dan Poin Reward
            _buildProfileSection(),
            const SizedBox(height: 24),
            // Bagian History Barang Dititipkan
            _buildItemHistorySection(context),
          ],
        ),
      ),
    );
  }

  // Widget untuk bagian profil, saldo, dan poin reward
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
                  'Jane Doe', // Nama penitip (bisa diganti dengan data dinamis)
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF354024),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'jane.doe@example.com', // Email penitip
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
                      'Saldo: Rp250,000', // Saldo (bisa diganti dengan data dinamis)
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
                      'Poin Reward: 200', // Poin reward (bisa diganti dengan data dinamis)
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

  // Widget untuk bagian history barang dititipkan
  Widget _buildItemHistorySection(BuildContext context) {
    // Data dummy untuk history barang dititipkan
    final List<Map<String, dynamic>> items = [
      {
        'id': 'ITEM001',
        'name': 'Meja Bekas',
        'category': 'Perabot',
        'date': '27 Mei 2025',
        'status': 'Tersedia',
        'price': 100000,
      },
      {
        'id': 'ITEM002',
        'name': 'Kursi Plastik',
        'category': 'Perabot',
        'date': '26 Mei 2025',
        'status': 'Terjual',
        'price': 50000,
      },
      {
        'id': 'ITEM003',
        'name': 'TV Second',
        'category': 'Elektronik',
        'date': '25 Mei 2025',
        'status': 'Tersedia',
        'price': 200000,
      },
    ];

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
                // Navigasi ke halaman semua history (opsional)
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
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal: ${item['date']} | Harga: Rp${item['price']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Status: ${item['status']}',
                      style: TextStyle(
                        color: item['status'] == 'Terjual'
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF354024),
                  size: 16,
                ),
                onTap: () {
                  // Navigasi ke halaman detail barang (opsional)
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => ItemDetailPage(item: item),
                  //   ),
                  // );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}