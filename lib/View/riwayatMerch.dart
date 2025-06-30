import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reuse_mart/view/loginPage.dart';

// Constants
const Color _primaryColor = Color(0xFF354024);
const Color _backgroundColor = Color(0xFFCFBB99);
const Color _disabledColor = Color(0xFFBBBBBB);
const String _baseUrl = 'https://api2.reuse-mart.com';

class ClaimHistoryPage extends StatefulWidget {
  const ClaimHistoryPage({super.key});

  @override
  State<ClaimHistoryPage> createState() => _ClaimHistoryPageState();
}

class _ClaimHistoryPageState extends State<ClaimHistoryPage> {
  List<Map<String, dynamic>> _claimList = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  int? _idPembeli;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // Check user authentication and get id_pembeli
  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final role = prefs.getString('role');
    _idPembeli = prefs.getInt('id_pembeli');

    if (authToken != null && role == 'pembeli' && _idPembeli != null) {
      setState(() => _isAuthenticated = true);
      await _fetchClaimHistory();
    } else {
      _redirectToLogin();
    }
  }

  // Fetch claim history based on id_pembeli
  Future<void> _fetchClaimHistory() async {
    if (_idPembeli == null) {
      setState(() {
        _errorMessage = 'User ID not found';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/claim-merchandise/pembeli?id_pembeli=$_idPembeli'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Request timed out'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          _claimList = data
              .map((item) => {
                    'nama_merch': item['merchandise']['nama_merch'],
                    'poin_tukar': item['merchandise']['poin_tukar'],
                    'tanggal_pengajuan': item['tanggal_pengajuan'],
                    'status_ambil': item['status_ambil'],
                  })
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load claim history: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load claim history: $e';
      });
      _showSnackBar(_errorMessage!, isError: true);
    }
  }

  // Redirect to login page
  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Show snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : _primaryColor,
      ),
    );
  }

  // Format date to dd/mm/yyyy
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month/$year';
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        title: const Text(
          'Claim History',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  // Build page body
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: _primaryColor));
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_claimList.isEmpty) {
      return const Center(child: Text('No claim history available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Claim History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _claimList.length,
            itemBuilder: (context, index) => _buildClaimCard(_claimList[index]),
          ),
        ],
      ),
    );
  }

  // Build claim card
  Widget _buildClaimCard(Map<String, dynamic> claim) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              claim['nama_merch'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text('Points: ${claim['poin_tukar']}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            Text('Date: ${formatDate(claim['tanggal_pengajuan'])}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            Text('Status: ${claim['status_ambil']}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
