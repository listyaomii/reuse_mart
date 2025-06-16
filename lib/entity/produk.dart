class Produk {
  final String id;
  final String name;
  final String status_produk;
  final double price;
  final String mainImage;
  final List<String> additionalImages;
  final String category;
  final String? warranty;
  final String warrantyStatus;
  final bool isWarrantyActive;
  final int rating;
  final String description;

  Produk({
    required this.id,
    required this.name,
    required this.status_produk,
    required this.price,
    required this.mainImage,
    required this.additionalImages,
    required this.category,
    this.warranty,
    required this.warrantyStatus,
    required this.isWarrantyActive,
    required this.rating,
    required this.description,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    final warrantyInfo = _checkWarrantyStatus(json['tgl_garansi']);
    final mainImage = json['gambar'] != null && json['gambar'].isNotEmpty
        ? 'http://192.168.35.56:8000/storage/${json['gambar'][0]['nama_gambar']}'
        : '/placeholder.jpg';

    return Produk(
      id: json['kode_produk'] ?? '',
      name: json['nama_produk'] ?? 'Unnamed Product',
      status_produk: json['status_produk'] ?? 'Tidak diketahui',
      price: (json['harga_jual'] ?? json['harga_produk'] ?? 0).toDouble(),
      mainImage: mainImage,
      additionalImages: json['gambar'] != null
          ? (json['gambar'] as List)
              .map((img) => 'http://192.168.35.56:8000/storage/${img['nama_gambar']}')
              .toList()
          : [],
      category: json['kategori'] != null ? json['kategori']['nama_kategori'] ?? 'Lainnya' : 'Lainnya',
      warranty: json['tgl_garansi'] != null ? _formatDate(json['tgl_garansi']) : null,
      warrantyStatus: warrantyInfo['status']!,
      isWarrantyActive: warrantyInfo['isActive']!,
      rating: json['rating_penitip_rata'] != null
          ? json['rating_penitip_rata'].toInt()
          : (json['rating'] != null ? json['rating'].toInt() : (1 + (json['kode_produk'].hashCode % 5))),
      description: json['deskripsi'] ?? json['deskripsi_produk'] ?? 'Tidak ada deskripsi tersedia.',
    );
  }
}

Map<String, dynamic> _checkWarrantyStatus(String? warrantyDate) {
  if (warrantyDate == null || warrantyDate == '0000-00-00' || warrantyDate == '0000-00-00 00:00:00') {
    return {'status': 'Tidak ada garansi', 'isActive': false};
  }
  try {
    final warrantyEndDate = DateTime.parse(warrantyDate);
    final currentDate = DateTime.now();
    if (warrantyEndDate.isAfter(currentDate)) {
      return {'status': 'Aktif', 'isActive': true};
    }
    return {'status': 'Kadaluarsa', 'isActive': false};
  } catch (error) {
    return {'status': 'Error format tanggal', 'isActive': false};
  }
}

String _formatDate(String? dateString) {
  if (dateString == null || dateString == '0000-00-00' || dateString == '0000-00-00 00:00:00') {
    return 'Tidak ada';
  }
  try {
    final date = DateTime.parse(dateString);
    return '${date.day} ${_getMonthName(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } catch (error) {
    return 'Error format tanggal';
  }
}

String _getMonthName(int month) {
  const months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  return months[month - 1];
}