import 'dart:convert';

// lib/models/user.dart
class User {
  final String token;
  final String role;
  final String? jabatan;
  final Map<String, dynamic> userData; // Data spesifik pengguna (name, email, dll.)

  User({
    required this.token,
    required this.role,
    this.jabatan,
    required this.userData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'],
      role: json['role'],
      jabatan: json['jabatan'],
      userData: json['user'] ?? {}, // 'user' berisi data seperti name, email dari backend
    );
  }

  // Getter untuk mengakses data spesifik dari userData
  String get name => userData['name'] ?? '';
  String get email => userData['email'] ?? '';
}