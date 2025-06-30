import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reuse_mart/entity/TransaksiPenjualan.dart';

class TransaksiPenjualanClient {
  static const String baseUrl = 'https://api2.reuse-mart.com';
  static const String endpoint = 'api/transaksi/penjualan';

  static Future<List<TransaksiPenjualan>> fetchAll(String token) async {
    try {
      print('Fetching transaksi with token: ${token.substring(0, 20)}...');
      var response = await http.get(
        Uri.parse('$baseUrl/$endpoint/historyMobile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> list = jsonData['data']['data'] ?? [];
          print('Found ${list.length} transactions');
          return list.map((e) => TransaksiPenjualan.fromJson(e)).toList();
        } else {
          print('API success is false or data is null: ${jsonData['message']}');
          throw Exception(jsonData['message'] ?? 'Gagal memuat transaksi');
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized access: Token might be invalid');
        throw Exception('Unauthorized: Token might be invalid');
      } else {
        print('Unexpected status code: ${response.statusCode}');
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e, stackTrace) {
      print('Error in fetchAll: $e, StackTrace: $stackTrace');
      if (e is http.ClientException) {
        print('Network error: Check server connection');
      }
      return Future.error('Gagal memuat transaksi: $e');
    }
  }

  static Future<DetailPenjualan> historyByID(String token, int id) async {
    try {
      print(
          'Fetching transaction by ID: $id with token: ${token.substring(0, 20)}');
      var response = await http.get(
        Uri.parse('$baseUrl/api/transaksi/penjualan/historyByIDMobile/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          return DetailPenjualan.fromJson(jsonResponse['data']);
        } else {
          print('API success is false: ${jsonResponse['message']}');
          throw Exception(jsonResponse['message']);
        }
      } else {
        print('Unexpected status code: ${response.statusCode}');
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e, stackTrace) {
      print('❌ Error in historyByID: $e, StackTrace: $stackTrace');
      return Future.error(e.toString());
    }
  }
}
