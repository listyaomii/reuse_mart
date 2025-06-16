import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reuse_mart/entity/pegawai.dart';

class PegawaiClient {
  final String baseUrl;

  PegawaiClient({required this.baseUrl});

  // Fetch Pegawai data by id_pegawai
  Future<Pegawai> fetchPegawaiById(String idPegawai) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Unauthorized: No auth token found');
      }

      // Ensure idPegawai is treated as a String
      final String id = idPegawai.toString();

      final response = await http.get(
        Uri.parse('$baseUrl/api/pegawai/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timed out'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Pegawai.fromJson(json['data'] ?? json);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch Pegawai data');
      }
    } catch (e) {
      throw Exception('Error fetching Pegawai data: $e');
    }
  }
}