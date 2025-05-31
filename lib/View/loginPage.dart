import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reuse_mart/entity/user.dart'; // Sesuaikan path
import 'package:reuse_mart/client/loginClient.dart'; // Sesuaikan path
import 'package:reuse_mart/view/pembeliHome.dart';
import 'package:reuse_mart/view/penitipHome.dart'; // Asumsi nama file untuk SellerProfilePage
import 'package:reuse_mart/view/hunterHome.dart'; // Asumsi nama file untuk HunterProfilePage
import 'package:reuse_mart/view/kurirHome.dart'; // Asumsi nama file untuk CourierProfilePage

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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final user = await authService.login(emailController.text, passwordController.text);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', user.token);
      await prefs.setString('role', user.role);
      if (user.jabatan != null) {
        await prefs.setString('jabatan', user.jabatan!);
      }

      if (user.role == 'pembeli') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Pembelihome()),
        );
      } else if (user.role == 'penitip') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SellerProfilePage()),
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
            MaterialPageRoute(builder: (context) => const CourierProfilePage()),
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
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(
                      color: Color(0xFF354024),
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