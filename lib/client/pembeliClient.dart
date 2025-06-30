import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reuse_mart/entity/Pembeli.dart';

class PembeliClient {
  static const String baseUrl = 'https://api2.reuse-mart.com';
  static const String endpoint = 'api/pembeli';

  static Future<List<Pembeli>> fetchAll(String token) async {
    try {
      var response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Fetch All - Status Code: ${response.statusCode}');
      print('Fetch All - Response Body: ${response.body}');

      if (response.statusCode != 200) throw Exception(response.reasonPhrase);

      Iterable list = json.decode(response.body)['data'];
      return list.map((e) => Pembeli.fromJson(e)).toList();
    } catch (e) {
      print('Error in fetchAll: $e');
      return Future.error(e.toString());
    }
  }

  static Future<http.Response> showMobile(String token) async {
    try {
      print('Token being sent: $token');

      var response = await http.get(
        Uri.parse('$baseUrl/api/pembeli/showMobile'), // Pastikan path lengkap
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('ShowMobile - Status Code: ${response.statusCode}');
      print('ShowMobile - Response Body: ${response.body}');
      print('ShowMobile - Request URL: $baseUrl/api/pembeli/showMobile');

      if (response.statusCode != 200) {
        print(
            'Error Response: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('${response.statusCode}: ${response.reasonPhrase}');
      }

      return response;
    } catch (e) {
      print('Error in showMobile: $e');
      return Future.error(e.toString());
    }
  }

  // Method tambahan untuk debugging
  static Future<bool> validateToken(String token) async {
    try {
      var response = await http.get(
        Uri.parse('$baseUrl/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Token validation - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }
}
