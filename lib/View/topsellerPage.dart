import 'package:flutter/material.dart';
import 'package:reuse_mart/client/TopSellerClient.dart';
import 'package:reuse_mart/entity/TopSeller.dart';

class Topsellerpage extends StatefulWidget {
  const Topsellerpage({super.key});

  @override
  State<Topsellerpage> createState() => _TopsellerpageState();
}

class _TopsellerpageState extends State<Topsellerpage> {
  final String token = 'your_valid_token_here'; // Ganti dengan token nyata

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFCFBB99), // Beige dari gambar
        child: FutureBuilder<TopSeller>(
          future: TopSellerClient.getTopSeller(token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: const Color(0xFF354024)));
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: const Color(0xFF354024))));
            } else if (snapshot.hasData) {
              final topSeller = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Seller Bulan Ini',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF354024)),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.star,
                                color: const Color(0xFF354024), size: 40),
                            const SizedBox(height: 10),
                            Text(
                              'ID Top Seller: ${topSeller.idTopSeller ?? "Tidak ada"}',
                              style: const TextStyle(
                                  fontSize: 16, color: const Color(0xFF354024)),
                            ),
                            Text(
                              'Penitip: ${topSeller.penitip?.namaPenitip ?? "Tidak ada"}',
                              style: const TextStyle(
                                  fontSize: 16, color: const Color(0xFF354024)),
                            ),
                            Text(
                              'Periode: ${topSeller.tglMulai?.toLocal() ?? "Tidak ada"} - ${topSeller.tglSelesai?.toLocal() ?? "Tidak ada"}',
                              style: const TextStyle(
                                  fontSize: 16, color: const Color(0xFF354024)),
                            ),
                            Text(
                              'Badge: ${topSeller.penitip?.badge ?? "Tidak ada"}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF354024)),
                            ),
                            Text(
                              'Saldo: ${topSeller.penitip?.saldoPenitip?.toStringAsFixed(2) ?? "0.00"}',
                              style: const TextStyle(
                                  fontSize: 16, color: const Color(0xFF354024)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(
                child: Text('Tidak ada data Top Seller',
                    style: TextStyle(color: const Color(0xFF354024))));
          },
        ),
      ),
    );
  }
}
