import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reuse_mart/entity/komisi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KomisiClient {
  final String baseUrl;

  KomisiClient({required this.baseUrl});

  Future<List<Komisi>> getKomisiByPegawai(String idPegawai) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      if (authToken == null) {
        throw Exception('Token autentikasi tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/komisi/$idPegawai'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => Komisi.fromJson(json)).toList();
        } else {
          throw Exception(jsonResponse['message'] ?? 'Gagal mengambil komisi');
        }
      } else {
        throw Exception('Gagal mengambil komisi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error mengambil komisi: $e');
    }
  }
}