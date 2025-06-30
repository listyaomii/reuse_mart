// kurirClient.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class KurirClient {
  static const String baseUrl =
      'https://api2.reuse-mart.com/api'; // Adjust based on your backend server IP

  // Fetch courier profile
  Future<Map<String, dynamic>> getProfileKurir(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile-kurir'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  // Fetch delivery history
  Future<List<Map<String, dynamic>>> getHistoryPengirimanKurir(String token,
      {String? statusPenjualan, int perPage = 10}) async {
    final uri = Uri.parse('$baseUrl/history-pengiriman-kurir')
        .replace(queryParameters: {
      'per_page': perPage.toString(),
      if (statusPenjualan != null) 'status_penjualan': statusPenjualan,
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return List<Map<String, dynamic>>.from(data['data']['data']);
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception(
          'Failed to load delivery history: ${response.statusCode}');
    }
  }

  // Update delivery status to "Selesai"
  Future<Map<String, dynamic>> updateStatusSelesai(
      String token, String idPenjualan) async {
    final url = Uri.parse('$baseUrl/kurir/update-status/$idPenjualan');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status_penjualan':
            'selesai', // Kirim status "selesai" sebagai body JSON
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['transaksi'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to update status: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateStatus(
      String token, String idPenjualan, String status) async {
    final url = Uri.parse('$baseUrl/kurir/update-status/$idPenjualan');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status_penjualan': status,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['transaksi'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to update status: ${response.statusCode}');
    }
  }
}
