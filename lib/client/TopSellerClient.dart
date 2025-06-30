import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reuse_mart/entity/TopSeller.dart';
import 'package:reuse_mart/entity/penitip.dart';

class TopSellerClient {
  static const String baseUrl = 'https://api2.reuse-mart.com';

  // Fungsi untuk mengambil data Top Seller
  static Future<TopSeller> getTopSeller(String token) async {
    try {
      print('Getting Top Seller with token: ${token.substring(0, 20)}...');

      var response = await http.get(
        Uri.parse('$baseUrl/api/calculate-top-seller'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Top Seller Response status: ${response.statusCode}');
      print('Top Seller Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['message'] == 'Top Seller berhasil dihitung') {
          // Asumsi ada 'top_seller' di respons
          return TopSeller.fromJson(jsonData['top_seller']);
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal mengambil Top Seller');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in getTopSeller: $e');
      throw Exception('Gagal mengambil Top Seller: $e');
    }
  }

  // Fungsi untuk mengambil daftar Top Seller (opsional, jika ada endpoint)
  static Future<List<TopSeller>> getAllTopSellers(String token) async {
    try {
      print('Getting all Top Sellers with token: ${token.substring(0, 20)}...');

      var response = await http.get(
        Uri.parse('$baseUrl/top-sellers'), // Sesuaikan endpoint jika ada
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('All Top Sellers Response status: ${response.statusCode}');
      print('All Top Sellers Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> list = jsonData['data'] ?? [];

          print('Raw data type: ${jsonData['data'].runtimeType}');
          if (list.isNotEmpty) {
            print('First item sample: ${list.first}');
            print(
                'First item id_topSeller type: ${list.first['id_topSeller'].runtimeType}');
          }

          return list.map((e) {
            try {
              return TopSeller.fromJson(e);
            } catch (parseError) {
              print('Error parsing item: $e');
              print('Parse error: $parseError');
              rethrow;
            }
          }).toList();
        } else {
          throw Exception(
              jsonData['message'] ?? 'Gagal mengambil daftar Top Seller');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in getAllTopSellers: $e');
      throw Exception('Gagal mengambil daftar Top Seller: $e');
    }
  }
}
