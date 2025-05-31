import 'package:flutter/material.dart';

class CourierProfilePage extends StatefulWidget {
  const CourierProfilePage({super.key});

  @override
  State<CourierProfilePage> createState() => _CourierProfilePageState();
}

class _CourierProfilePageState extends State<CourierProfilePage> {
  // Data dummy untuk history tugas pengiriman
  List<Map<String, dynamic>> deliveryTasks = [
    {
      'id': 'DEL001',
      'item': 'Meja Bekas',
      'destination': 'Jakarta Selatan',
      'date': '29 Mei 2025',
      'status': 'Pending',
    },
    {
      'id': 'DEL002',
      'item': 'Kursi Plastik',
      'destination': 'Bandung',
      'date': '29 Mei 2025',
      'status': 'Pending',
    },
    {
      'id': 'DEL003',
      'item': 'TV Second',
      'destination': 'Surabaya',
      'date': '30 Mei 2025',
      'status': 'Pending',
    },
  ];

  // Fungsi untuk mengupdate status pengiriman
  void _updateDeliveryStatus(String taskId, String newStatus) {
    setState(() {
      final taskIndex = deliveryTasks.indexWhere((task) => task['id'] == taskId);
      if (taskIndex != -1) {
        deliveryTasks[taskIndex]['status'] = newStatus;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFBB99), // Warna background krem kecokelatan
      appBar: AppBar(
        backgroundColor: const Color(0xFF354024), // Hijau tua
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
            // Bagian Profil
            _buildProfileSection(),
            const SizedBox(height: 24),
            // Bagian History Tugas Pengiriman
            _buildDeliveryHistorySection(),
          ],
        ),
      ),
    );
  }

  // Widget untuk bagian profil
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
                  'Rudi Kurir', // Nama kurir (bisa diganti dengan data dinamis)
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF354024),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'rudi.kurir@example.com', // Email kurir
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk bagian history tugas pengiriman
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: deliveryTasks.length,
          itemBuilder: (context, index) {
            final task = deliveryTasks[index];
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
                  'Tugas #${task['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF354024),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item: ${task['item']} | Tujuan: ${task['destination']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Tanggal: ${task['date']} | Status: ${task['status']}',
                      style: TextStyle(
                        color: task['status'] == 'Selesai'
                            ? Colors.green
                            : task['status'] == 'Dikirimkan'
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
                      onPressed: task['status'] == 'Pending'
                          ? () {
                              _updateDeliveryStatus(task['id'], 'Dikirimkan');
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
                      onPressed: task['status'] == 'Dikirimkan'
                          ? () {
                              _updateDeliveryStatus(task['id'], 'Selesai');
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