import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reuse_mart/entity/produk.dart';
import 'package:reuse_mart/entity/kategori.dart';

class ProdukClient {
  static const String baseUrl = 'http://192.168.35.56:8000/api'; // Untuk emulator Android

  Future<List<Produk>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/produk')).timeout(Duration(seconds: 60));
      print('fetchProducts Status Code: ${response.statusCode}');
      print('fetchProducts Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final filteredData = data.where((json) => json['status_produk'] == 'tersedia').toList();
        print('Produk tersedia: ${filteredData.length}');
        return filteredData.map((json) => Produk.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat produk: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('fetchProducts Error: $e');
      rethrow;
    }
  }

  Future<Produk> fetchProductDetail(String productId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/produk/$productId')).timeout(Duration(seconds: 10));
      print('fetchProductDetail Status Code: ${response.statusCode}');
      print('fetchProductDetail Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Produk.fromJson(data);
      } else {
        throw Exception('Gagal memuat detail produk: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('fetchProductDetail Error: $e');
      rethrow;
    }
  }

  Future<List<Kategori>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/kategori')).timeout(Duration(seconds: 10));
      print('fetchCategories Status Code: ${response.statusCode}');
      print('fetchCategories Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Kategori.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat kategori: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('fetchCategories Error: $e');
      rethrow;
    }
  }
}

