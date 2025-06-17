import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reuse_mart/entity/user.dart'; // Sesuaikan path proyekmu
import 'package:reuse_mart/entity/pegawai.dart';
import 'package:reuse_mart/entity/pembeli.dart';
import 'package:reuse_mart/entity/penitip.dart';
import 'dart:async'; // Tambahkan impor ini
import 'package:firebase_messaging/firebase_messaging.dart'; // Tambahkan impor ini

class AuthService {

  //static const String baseUrl = 'http://192.168.35.56:8000'; // IP komputer, sesuai ipconfig
  static const String baseUrl =
      'http://10.0.2.2:8000'; // IP komputer, sesuai ipconfig
  static const String endpoint = 'api/login';

  Future<User> login(String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      print('Mencoba koneksi ke: $uri');
      print('Data: ${jsonEncode({'email': email, 'password': password})}');

      final response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(
        const Duration(seconds: 60), // Naikkan ke 60 detik
        onTimeout: () {
          throw TimeoutException('Request ke server timeout');
        },
      );

      print('Status: ${response.statusCode}');
      print('Hasil: ${response.body}');

      if (response.statusCode == 200) {
        // Parse respons ke User
        final user = User.fromJson(jsonDecode(response.body));

        // Minta izin notifikasi
        final messaging = FirebaseMessaging.instance;
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false, // Opsional: izin sementara untuk iOS
        );
        print('Izin notifikasi: ${settings.authorizationStatus}');

        // Ambil FCM token jika izin diberikan
        if (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional) {
          String? fcmToken = await messaging.getToken();
          if (fcmToken != null) {
            print('FCM Token: $fcmToken');
            // Opsional: Kirim FCM token ke server (misalnya via API update token)
            await updateFcmToken(user.token, fcmToken);
          }
        }

        return user;
      } else {
        throw Exception('Login gagal');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Gagal terhubung: $e');
    }
  }

  // Fungsi untuk memperbarui FCM token di server (opsional)
  Future<void> updateFcmToken(String authToken, String fcmToken) async {
    try {
      final uri =
          Uri.parse('$baseUrl/api/update-fcm-token'); // Sesuaikan endpoint
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({'fcm_token': fcmToken}),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        print('Gagal memperbarui FCM token: ${response.body}');
        throw Exception('Gagal memperbarui FCM token');
      }
      print('FCM token berhasil diperbarui: ${response.body}');
    } catch (e) {
      print('Error saat memperbarui FCM token: $e');
      throw Exception('Gagal memperbarui FCM token: $e');
    }
  }
}
