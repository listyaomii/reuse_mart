import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reuse_mart/entity/merchandise.dart';

class MerchandiseClient {
  final String baseUrl;

  MerchandiseClient({required this.baseUrl});

  Future<List<Merchandise>> fetchMerchandise() async {
    try {
      final prefs = await SharedPreferences.getInstance(); 
      final authToken = prefs.getString('auth_token'); 
      final role = prefs.getString('role');
      if (authToken == null || role != 'pembeli') {
    throw Exception('Unauthorized: Please log in as a pembeli.');
  }

  final uri = Uri.parse('$baseUrl/api/merchandise');
  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $authToken',
    },
  ).timeout(
    const Duration(seconds: 60),
    onTimeout: () {
      throw TimeoutException('Request to fetch merchandise timed out');
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final List<dynamic> data = jsonResponse['data'];
    return data.map((item) => Merchandise.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load merchandise: ${response.statusCode} - ${response.body}');
  }
} catch (e) {
  throw Exception('Error fetching merchandise: $e');
}

} }

