import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reuse_mart/entity/TransaksiPenjualan.dart';

class TransaksiPenjualanClient {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String endpoint = 'api/transaksi/penjualan';

  static Future<List<TransaksiPenjualan>> fetchAll(String token) async {
    try {
      print('Fetching transaksi with token: ${token.substring(0, 20)}...');

      var response = await http.get(
        Uri.parse('$baseUrl/$endpoint/historyMobile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      final jsonData = json.decode(response.body);
      print('Parsed JSON: $jsonData');

      if (jsonData['success'] == true) {
        final List<dynamic> list = jsonData['data']['data'] ?? [];
        print('Found ${list.length} transactions');

        // Debug: print first item if exists
        if (list.isNotEmpty) {
          print('First transaction sample: ${list[0]}');
        }

        return list.map((e) => TransaksiPenjualan.fromJson(e)).toList();
      } else {
        throw Exception(jsonData['message'] ?? 'Gagal memuat transaksi');
      }
    } catch (e) {
      print('Error in fetchAll: $e');
      return Future.error('Gagal memuat transaksi: $e');
    }
  }

  static Future<DetailPenjualan> historyByID(String token, int id) async {
    try {
      print('Fetching transaction by ID: $id');

      var response = await http.get(
        Uri.parse('$baseUrl/api/transaksi/penjualan/historyByIDMobile/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        return DetailPenjualan.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['message']);
      }
    } catch (e) {
      print('❌ Error in historyByID: $e');
      return Future.error(e.toString());
    }
  }
}
