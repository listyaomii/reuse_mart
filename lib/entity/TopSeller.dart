class TopSeller {
  final int? idTopSeller;
  final String? idPenitip;
  final DateTime? tglMulai;
  final DateTime? tglSelesai;
  final Penitip? penitip;

  TopSeller({
    this.idTopSeller,
    this.idPenitip,
    this.tglMulai,
    this.tglSelesai,
    this.penitip,
  });

  factory TopSeller.fromJson(Map<String, dynamic> json) {
    return TopSeller(
      idTopSeller: _parseInt(json['id_topSeller']),
      idPenitip: json['id_penitip']?.toString(),
      tglMulai: json['tgl_mulai'] != null
          ? DateTime.tryParse(json['tgl_mulai'].toString())
          : null,
      tglSelesai: json['tgl_selesai'] != null
          ? DateTime.tryParse(json['tgl_selesai'].toString())
          : null,
      penitip:
          json['penitip'] != null ? Penitip.fromJson(json['penitip']) : null,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id_topSeller': idTopSeller,
      'id_penitip': idPenitip,
      'tgl_mulai': tglMulai?.toIso8601String(),
      'tgl_selesai': tglSelesai?.toIso8601String(),
      'penitip': penitip?.toJson(),
    };
  }
}

class Penitip {
  final String? idPenitip;
  final String? namaPenitip;
  final double? saldoPenitip;
  final String? badge; // Tambahkan field badge

  Penitip({
    this.idPenitip,
    this.namaPenitip,
    this.saldoPenitip,
    this.badge,
  });

  factory Penitip.fromJson(Map<String, dynamic> json) {
    return Penitip(
      idPenitip: json['id_penitip']?.toString(),
      namaPenitip: json['nama_penitip']?.toString(),
      saldoPenitip: double.tryParse(json['saldo_penitip']?.toString() ?? '0.0'),
      badge: json['badge']?.toString(), // Ambil badge dari JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_penitip': idPenitip,
      'nama_penitip': namaPenitip,
      'saldo_penitip': saldoPenitip,
      'badge': badge,
    };
  }
}
