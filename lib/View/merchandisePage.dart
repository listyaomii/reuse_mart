import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reuse_mart/view/loginPage.dart';
import 'package:reuse_mart/client/merchandiseClient.dart';
import 'package:reuse_mart/entity/merchandise.dart';
import 'package:reuse_mart/view/riwayatMerch.dart'; // Import halaman baru

// Constants
const Color _primaryColor = Color(0xFF354024);
const Color _backgroundColor = Color(0xFFCFBB99);
const Color _disabledColor = Color(0xFFBBBBBB);
const String _baseUrl = 'http://192.168.35.56:8000';

class MerchandisePage extends StatefulWidget {
  const MerchandisePage({super.key});

  @override
  State<MerchandisePage> createState() => _MerchandisePageState();
}

class _MerchandisePageState extends State<MerchandisePage> {
  final MerchandiseClient _merchClient = MerchandiseClient(baseUrl: _baseUrl);
  List<Merchandise> _merchandiseList = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // Check user authentication
  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final role = prefs.getString('role');

    if (authToken != null && role == 'pembeli') {
      setState(() => _isAuthenticated = true);
      await _fetchMerchandise();
    } else {
      _redirectToLogin();
    }
  }

  // Fetch merchandise from API
  Future<void> _fetchMerchandise() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchedMerch = await _merchClient.fetchMerchandise();
      setState(() {
        _merchandiseList = fetchedMerch;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load merchandise: $e';
      });
      _showSnackBar(_errorMessage!, isError: true);
    }
  }

  // Show claim confirmation dialog
  Future<void> _showClaimConfirmationDialog(Merchandise merch) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Claim'),
        content: Text(
          'Are you sure you want to claim ${merch.namaMerch}? '
          'This will use ${merch.poinTukar} points.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: _primaryColor)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _claimMerchandise(merch);
    }
  }

  // Claim merchandise via API
  Future<void> _claimMerchandise(Merchandise merch) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      final idPembeli = prefs.getInt('id_pembeli');

      if (authToken == null || idPembeli == null) {
        throw Exception('Please log in as a pembeli.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/claim-merchandise'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'id_merch': merch.idMerch,
          'id_pembeli': idPembeli,
          'tanggal_pengajuan': DateTime.now().toIso8601String().split('T')[0],
          'status_ambil': 'diproses',
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Claim request timed out'),
      );

      if (response.statusCode == 201) {
        _showSnackBar('Successfully claimed ${merch.namaMerch}!');
        await _fetchMerchandise();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to claim merchandise');
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        title: const Text(
          'Merchandise Catalog',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _isAuthenticated ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClaimHistoryPage()),
              );
            } : null,
            tooltip: 'View Claim History',
          ),
        ],
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
      return const Center(child: CircularProgressIndicator(color: _primaryColor));
    }
    if (_errorMessage != null) {
      return Center(
          child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    if (_merchandiseList.isEmpty) {
      return const Center(child: Text('No merchandise available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Redeem Your Points!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildMerchandiseList(),
        ],
      ),
    );
  }

  // Build merchandise list
  Widget _buildMerchandiseList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _merchandiseList.length,
      itemBuilder: (context, index) => _buildMerchandiseCard(_merchandiseList[index]),
    );
  }

  // Build merchandise card
  Widget _buildMerchandiseCard(Merchandise merch) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMerchandiseImage(),
            const SizedBox(width: 12),
            Expanded(child: _buildMerchandiseDetails(merch)),
          ],
        ),
      ),
    );
  }

  // Build merchandise image
  Widget _buildMerchandiseImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        'https://via.placeholder.com/100x100',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.image_not_supported,
          size: 100,
          color: _primaryColor,
        ),
      ),
    );
  }

  // Build merchandise details
  Widget _buildMerchandiseDetails(Merchandise merch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          merch.namaMerch,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text('Points: ${merch.poinTukar}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        Text('Stock: ${merch.stokMerch}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(height: 8),
        _buildClaimButton(merch),
      ],
    );
  }

  // Build claim button
  Widget _buildClaimButton(Merchandise merch) {
    return ElevatedButton(
      onPressed: merch.stokMerch > 0 ? () => _showClaimConfirmationDialog(merch) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        disabledBackgroundColor: _disabledColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Claim',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}