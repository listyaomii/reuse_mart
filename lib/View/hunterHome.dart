import 'package:flutter/material.dart';
import 'package:reuse_mart/View/komisiHunterPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reuse_mart/client/pegawaiClient.dart';
import 'package:reuse_mart/entity/pegawai.dart';

class HunterProfilePage extends StatefulWidget {
  const HunterProfilePage({super.key});

  @override
  State<HunterProfilePage> createState() => _HunterProfilePageState();
}

class _HunterProfilePageState extends State<HunterProfilePage> {
  final PegawaiClient _pegawaiClient =
      PegawaiClient(baseUrl: 'https://api2.reuse-mart.com');
  Pegawai? _pegawai;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPegawai();
  }

  // Fetch data pegawai menggunakan id_pegawai dari SharedPreferences
  Future<void> _fetchPegawai() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final idPegawai = prefs.getString('id_pegawai');
      if (idPegawai == null) {
        throw Exception('Tidak ada id_pegawai ditemukan di SharedPreferences');
      }

      // Ambil data pegawai
      final pegawai = await _pegawaiClient.fetchPegawaiById(idPegawai);

      setState(() {
        _pegawai = pegawai as Pegawai?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFBB99),
      appBar: AppBar(
        backgroundColor: const Color(0xFF354024),
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
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_token');
                await prefs.remove('id_pegawai');
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.logout, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF354024)))
          : _error != null
              ? Center(
                  child: Text('Error: $_error',
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileSection(context),
                    ],
                  ),
                ),
    );
  }

  // Widget untuk bagian profil dan saldo
  Widget _buildProfileSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 2,
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
                  _pegawai?.namaPegawai ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF354024),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _pegawai?.emailPegawai ?? 'No email',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final idPegawai = prefs.getString('id_pegawai');
                      if (idPegawai != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                KomisiPage(idPegawai: idPegawai),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'ID pegawai tidak ditemukan. Silakan login kembali.'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal navigasi: ${e.toString()}'),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF354024),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Saldo: Rp${double.tryParse(_pegawai?.saldoPegawai.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
