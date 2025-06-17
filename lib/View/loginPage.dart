import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reuse_mart/View/hunterHome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reuse_mart/entity/user.dart';
import 'package:reuse_mart/client/loginClient.dart'; 
import 'package:reuse_mart/view/pembeliHome.dart';
import 'package:reuse_mart/view/penitipHome.dart'; 
import 'package:reuse_mart/view/kurirHome.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'package:http/http.dart' as http; 
import 'dart:convert'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;


  //static const String baseUrl =
      //'http://192.168.120.61:8000'; // IP komputer, sesuai ipconfig

  static const String baseUrl = 'http://10.0.2.2:8000';


  Future<void> _updateFcmToken(String token, String fcmToken) async {
    try {
      final uri = Uri.parse('$baseUrl/api/update-fcm-token');
      final response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Request to update FCM token timed out');
        },
      );

      print('FCM Update Status: ${response.statusCode}');
      print('FCM Update Result: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update FCM token');
      }
    } catch (e) {
      print('FCM Update Error: $e');
      throw Exception('Failed to update FCM token: $e');
    }
  }

  // Clear session sebelum login baru
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Session cleared successfully');
    } catch (e) {
      print('Error clearing session: $e');
    }
  }

  Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });
    try {
      // Clear session terlebih dahulu sebelum login
      await _clearSession();

      final authService = AuthService();
      final user = await authService.login(
          emailController.text, passwordController.text);

      // Simpan data session baru
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', user.token);
      await prefs.setString('role', user.role);
      if (user.role == 'pembeli' && user.id != null) {
        await prefs.setInt('id_pembeli', user.id!);
      }
      if(user.role == 'pegawai' && user.id_pegawai != null) {
        await prefs.setString('id_pegawai', user.id_pegawai!);
      }
      if (user.jabatan != null) {
        await prefs.setString('jabatan', user.jabatan!);
      }

    // Dapatkan FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      // Update FCM token ke server
      await _updateFcmToken(user.token, fcmToken);
    } else {
      print('FCM Token tidak tersedia');
    }

    // Navigasi berdasarkan role
    if (user.role == 'pembeli') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Pembelihome()),
      );
    } else if (user.role == 'penitip') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
              // ✅ Fixed: Pass token as named parameter properly
              builder: (context) => SellerProfilePage(token: user.token),
            ),
      );
    } else if (user.role == 'pegawai') {
      if (user.jabatan == 'hunter') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HunterProfilePage()),
        );
      } else if (user.jabatan == 'kurir') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CourierProfilePage(token: user.token),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Jabatan tidak dikenali';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Role tidak dikenali';
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFBB99),
      appBar: AppBar(
        backgroundColor: const Color(0xFF354024),
        title: const Text(
          'Login ReuseMart',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 48),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.recycling, size: 50, color: Colors.black),
              ),
              const SizedBox(height: 36),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Masukkan email' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Masukkan password' : null,
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Column(
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF354024),
                        ),
                        SizedBox(height: 8),
                        Text('Sedang login...'),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF354024),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
