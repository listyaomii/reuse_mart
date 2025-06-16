class Komisi {
  final String namaProduk;
  final int idPenjualan;
  final double hargaJual;
  final double komisiHunter;
  final String tanggalBayar;
  final String namaPenitip;

  Komisi({
    required this.namaProduk,
    required this.idPenjualan,
    required this.hargaJual,
    required this.komisiHunter,
    required this.tanggalBayar,
    required this.namaPenitip,
  });

  factory Komisi.fromJson(Map<String, dynamic> json) {
    return Komisi(
      namaProduk: json['nama_produk'] as String? ?? 'Tidak tersedia',
      idPenjualan: (json['id_penjualan'] is int)
          ? json['id_penjualan'] as int
          : int.tryParse(json['id_penjualan'].toString()) ?? 0,
      hargaJual: (json['harga_jual'] as num?)?.toDouble() ?? 0.0,
      komisiHunter: (json['komisi_hunter'] as num?)?.toDouble() ?? 0.0,
      tanggalBayar: json['tanggal_bayar'] as String? ?? 'Tidak tersedia',
      namaPenitip: json['nama_penitip'] as String? ?? 'Null',
    );
  }
}