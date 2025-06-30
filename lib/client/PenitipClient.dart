import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reuse_mart/entity/penitip.dart';
import 'package:reuse_mart/entity/TransaksiPenitipan.dart';

class PenitipClient {
  static const String baseUrl = 'https://api2.reuse-mart.com';

  // Fungsi untuk mengambil profil penitip
  static Future<Penitip> getProfile(String token) async {
    try {
      print('Getting profile with token: ${token.substring(0, 20)}...');

      var response = await http.get(
        Uri.parse('$baseUrl/api/penitip/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Profile Response status: ${response.statusCode}');
      print('Profile Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return Penitip.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal mengambil profil');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in getProfile: $e');
      throw Exception('Gagal mengambil profil: $e');
    }
  }

  // Fungsi untuk mengambil riwayat penitipan
  static Future<List<TransaksiPenitipan>> getRiwayatPenitipan(
      String token) async {
    try {
      print('Getting riwayat with token: ${token.substring(0, 20)}...');

      var response = await http.get(
        Uri.parse('$baseUrl/api/transaksi-penitipan/riwayat-lengkap'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Riwayat Response status: ${response.statusCode}');
      print('Riwayat Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> list = jsonData['data'] ?? [];

          // Debug: print raw data untuk debugging
          print('Raw data type: ${jsonData['data'].runtimeType}');
          if (list.isNotEmpty) {
            print('First item sample: ${list.first}');
            print(
                'First item id_penitipan type: ${list.first['id_penitipan'].runtimeType}');
          }

          return list.map((e) {
            try {
              return TransaksiPenitipan.fromJson(e);
            } catch (parseError) {
              print('Error parsing item: $e');
              print('Parse error: $parseError');
              rethrow;
            }
          }).toList();
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal mengambil riwayat');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in getRiwayatPenitipan: $e');
      throw Exception('Gagal mengambil riwayat: $e');
    }
  }
}
