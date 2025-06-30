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
      idPenjualan: int.tryParse(json['id_penjualan'].toString()) ?? 0,
      hargaJual: double.tryParse(json['harga_jual'].toString()) ?? 0.0,
      komisiHunter: double.tryParse(json['komisi_hunter'].toString()) ?? 0.0,
      tanggalBayar: json['tanggal_bayar'] as String? ?? 'Tidak tersedia',
      namaPenitip: json['nama_penitip'] as String? ?? 'Tidak diketahui',
    );
  }
}
