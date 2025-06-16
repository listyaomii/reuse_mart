import 'dart:convert';

// lib/models/user.dart
class User {
  final int? id;
  final String? id_pegawai; // Tambahkan ini untuk pegawai
  final String token;
  final String role;
  final String? jabatan;
  final Map<String, dynamic> userData; // Data spesifik pengguna (name, email, dll.)

  User({
    this.id,
    this.id_pegawai, // Inisialisasi id_pegawai
    required this.token,
    required this.role,
    this.jabatan,
    required this.userData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id_pembeli'],
      id_pegawai: json['user']['id_pegawai'], // Ambil id_pegawai jika ada
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