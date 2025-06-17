// File: lib/services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ✅ Method logout yang konsisten untuk semua halaman
  static Future<bool> logout(BuildContext context,
      {bool showConfirmation = true}) async {
    bool shouldLogout = true;

    if (showConfirmation) {
      shouldLogout = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Konfirmasi Logout'),
                content: const Text('Apakah Anda yakin ingin keluar?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Ya, Keluar'),
                  ),
                ],
              );
            },
          ) ??
          false;
    }

    if (shouldLogout) {
      try {
        // ✅ Clear semua data session
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // Clear semua data untuk memastikan tidak ada sisa

        print('Logout successful - All session data cleared');

        // ✅ Tampilkan pesan sukses
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil logout'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // ✅ Navigate ke login dan clear semua navigation stack
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false, // Remove semua route sebelumnya
          );
        }

        return true;
      } catch (e) {
        print('Logout error: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    }

    return false;
  }

  // ✅ Method untuk validasi session
  static Future<Map<String, String?>> getSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'token': prefs.getString('auth_token'),
        'role': prefs.getString('role'),
        'jabatan': prefs.getString('jabatan'),
        'email': prefs.getString('user_email'),
      };
    } catch (e) {
      print('Error getting session data: $e');
      return {
        'token': null,
        'role': null,
        'jabatan': null,
        'email': null,
      };
    }
  }

  // ✅ Method untuk handle authentication error
  static Future<void> handleAuthError(
      BuildContext context, String error) async {
    print('Authentication error: $error');

    // Clear session
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi telah berakhir. Silakan login kembali.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to login
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    }
  }

  // ✅ Method untuk debug session info
  static Future<void> debugSessionInfo() async {
    try {
      final sessionData = await getSessionData();
      print('=== SESSION DEBUG INFO ===');
      print('Token: ${sessionData['token']?.substring(0, 20) ?? 'null'}...');
      print('Role: ${sessionData['role']}');
      print('Jabatan: ${sessionData['jabatan']}');
      print('Email: ${sessionData['email']}');
      print('========================');
    } catch (e) {
      print('Debug session error: $e');
    }
  }
}
