class TransaksiPenitipan {
  final String idPenitipan;
  final String idPenitip;
  final String? namaPenitip;
  final String? alamat;
  final String idPegawai;
  final String? petugasQC;
  final String idHunter;
  final String? namaHunter;
  final String? tanggalTitip;
  final String? tanggalLaku;
  final int masaPenitipan;
  final List<DetailPenitipan> details;

  TransaksiPenitipan({
    required this.idPenitipan,
    required this.idPenitip,
    this.namaPenitip,
    this.alamat,
    required this.idPegawai,
    this.petugasQC,
    required this.idHunter,
    this.namaHunter,
    this.tanggalTitip,
    this.tanggalLaku,
    required this.masaPenitipan,
    required this.details,
  });

  factory TransaksiPenitipan.fromJson(Map<String, dynamic> json) {
    var detailsJson = json['details'] as List<dynamic>? ?? [];
    return TransaksiPenitipan(
      // Konversi ke String jika perlu
      idPenitipan: json['id_penitipan']?.toString() ?? '',
      idPenitip: json['id_penitip']?.toString() ?? '',
      namaPenitip: json['nama_penitip']?.toString(),
      alamat: json['alamat']?.toString(),
      idPegawai: json['id_pegawai']?.toString() ?? '',
      petugasQC: json['petugasQC']?.toString(),
      idHunter: json['id_hunter']?.toString() ?? '',
      namaHunter: json['nama_hunter']?.toString(),
      tanggalTitip: json['tanggal_titip']?.toString(),
      tanggalLaku: json['tanggal_laku']?.toString(),
      // Pastikan ini tetap int
      masaPenitipan: json['masa_penitipan'] is int 
          ? json['masa_penitipan'] 
          : int.tryParse(json['masa_penitipan']?.toString() ?? '0') ?? 0,
      details: detailsJson.map((detail) => DetailPenitipan.fromJson(detail)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_penitipan': idPenitipan,
      'id_penitip': idPenitip,
      'nama_penitip': namaPenitip,
      'alamat': alamat,
      'id_pegawai': idPegawai,
      'petugasQC': petugasQC,
      'id_hunter': idHunter,
      'nama_hunter': namaHunter,
      'tanggal_titip': tanggalTitip,
      'tanggal_laku': tanggalLaku,
      'masa_penitipan': masaPenitipan,
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }
}

class DetailPenitipan {
  final String idDetailPenitipan;
  final String kodeProduk;
  final Map<String, dynamic> produk;

  DetailPenitipan({
    required this.idDetailPenitipan,
    required this.kodeProduk,
    required this.produk,
  });

  factory DetailPenitipan.fromJson(Map<String, dynamic> json) {
    return DetailPenitipan(
      // Konversi ke String untuk konsistensi
      idDetailPenitipan: json['id_detailPenitipan']?.toString() ?? '',
      kodeProduk: json['kode_produk']?.toString() ?? '',
      produk: Map<String, dynamic>.from(json['produk'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_detailPenitipan': idDetailPenitipan,
      'kode_produk': kodeProduk,
      'produk': produk,
    };
  }
}