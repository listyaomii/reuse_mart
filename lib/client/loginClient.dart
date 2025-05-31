// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reuse_mart/entity/user.dart'; // Sesuaikan path proyekmu
import 'package:reuse_mart/entity/pegawai.dart';
import 'package:reuse_mart/entity/pembeli.dart';
import 'package:reuse_mart/entity/penitip.dart';
import 'dart:async'; // Tambahkan impor ini

class AuthService {
  static const String baseUrl = 'http://192.168.120.61:8000'; // IP komputer, sesuai ipconfig
  static const String endpoint = 'api/login';
Future<User> login(String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      print('Mencoba koneksi ke: $uri');
      print('Data: ${jsonEncode({'email': email, 'password': password})}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(
        const Duration(seconds: 60), // Naikkan ke 60 detik
        onTimeout: () {
          throw TimeoutException('Request ke server timeout');
        },
      );

      print('Status: ${response.statusCode}');
      print('Hasil: ${response.body}');

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Login gagal');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Gagal terhubung: $e');
    }
  }
}