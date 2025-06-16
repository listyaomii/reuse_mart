class TransaksiPenjualan {
  final String? idTransaksiPenjualan;
  final String? idMember;
  final String? jenisPengambilan;
  final DateTime? tanggalPesan;
  final DateTime? tanggalBayar;
  final DateTime? tanggalAmbil;
  final double? ongkir;
  final double? totalHarga;
  final int poinDitukar;
  final int poinDidapat;
  final String? statusPembayaran;
  final String? statusPenjualan;
  final String? idAlamat;
  final Alamat? alamat;
  final List<DetailPenjualan>? detailPenjualan;
  final Pembeli? pembeli;

  TransaksiPenjualan({
    this.idTransaksiPenjualan,
    this.idMember,
    this.jenisPengambilan,
    this.tanggalPesan,
    this.tanggalBayar,
    this.tanggalAmbil,
    this.ongkir,
    this.totalHarga,
    this.poinDitukar = 0,
    this.poinDidapat = 0,
    this.statusPembayaran,
    this.statusPenjualan,
    this.idAlamat,
    this.alamat,
    this.detailPenjualan,
    this.pembeli,
  });

  factory TransaksiPenjualan.fromJson(Map<String, dynamic> json) {
    return TransaksiPenjualan(
      // Pastikan semua ID dikonversi ke String
      idTransaksiPenjualan: json['id_transaksipenjualan']?.toString() ??
          json['id_transaksi_penjualan']?.toString(),
      idMember: json['id_pembeli']?.toString() ?? json['id_member']?.toString(),
      jenisPengambilan: json['jenis_pengambilan']?.toString(),
      tanggalPesan: json['tanggal_pesan'] != null
          ? DateTime.tryParse(json['tanggal_pesan'].toString())
          : null,
      tanggalBayar: json['tanggal_bayar'] != null
          ? DateTime.tryParse(json['tanggal_bayar'].toString())
          : null,
      tanggalAmbil: json['tanggal_ambil'] != null
          ? DateTime.tryParse(json['tanggal_ambil'].toString())
          : null,
      // Safe parsing untuk numeric values
      ongkir: _parseDouble(json['ongkir']),
      totalHarga: _parseDouble(json['total_harga']),
      poinDitukar: _parseInt(json['poin_ditukar']) ?? 0,
      poinDidapat: _parseInt(json['poin_didapat']) ?? 0,
      statusPembayaran: json['status_pembayaran']?.toString(),
      statusPenjualan: json['status_penjualan']?.toString(),
      idAlamat: json['id_alamat']?.toString(),
      alamat: json['alamat'] != null ? Alamat.fromJson(json['alamat']) : null,
      detailPenjualan: json['detail_penjualan'] != null
          ? (json['detail_penjualan'] as List)
              .map((e) => DetailPenjualan.fromJson(e))
              .toList()
          : null,
      pembeli:
          json['pembeli'] != null ? Pembeli.fromJson(json['pembeli']) : null,
    );
  }

  // Helper methods untuk safe parsing
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id_transaksipenjualan': idTransaksiPenjualan,
      'id_pembeli': idMember,
      'jenis_pengambilan': jenisPengambilan,
      'tanggal_pesan': tanggalPesan?.toIso8601String(),
      'tanggal_bayar': tanggalBayar?.toIso8601String(),
      'tanggal_ambil': tanggalAmbil?.toIso8601String(),
      'ongkir': ongkir,
      'total_harga': totalHarga,
      'poin_ditukar': poinDitukar,
      'poin_didapat': poinDidapat,
      'status_pembayaran': statusPembayaran,
      'status_penjualan': statusPenjualan,
      'id_alamat': idAlamat,
      'alamat': alamat?.toJson(),
      'detail_penjualan': detailPenjualan?.map((e) => e.toJson()).toList(),
      'pembeli': pembeli?.toJson(),
    };
  }
}

class DetailPenjualan {
  final String? idDetailPenjualan; // Changed from int to String
  final String? idTransaksiPenjualan;
  final String? kodeProduk;
  final Produk? produk;

  DetailPenjualan({
    this.idDetailPenjualan,
    this.idTransaksiPenjualan,
    this.kodeProduk,
    this.produk,
  });

  factory DetailPenjualan.fromJson(Map<String, dynamic> json) {
    return DetailPenjualan(
      // Safe parsing untuk ID
      idDetailPenjualan: json['id_detail_penjualan']?.toString(),
      idTransaksiPenjualan: json['id_transaksipenjualan']?.toString() ??
          json['id_transaksi_penjualan']?.toString() ??
          json['id_penjualan']?.toString(),
      kodeProduk: json['kode_produk']?.toString(),
      produk: json['produk'] != null ? Produk.fromJson(json['produk']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_detail_penjualan': idDetailPenjualan,
      'id_transaksipenjualan': idTransaksiPenjualan,
      'kode_produk': kodeProduk,
      'produk': produk?.toJson(),
    };
  }
}

class Produk {
  final String? kodeProduk;
  final int? idKategori;
  final String? namaProduk;
  final DateTime? tanggalMasuk;
  final DateTime? tanggalAmbil;
  final double? harga;
  final String? statusProduk;
  final String? deskripsi;
  final double? berat;
  final DateTime? tglGaransi;
  final DateTime? batasAmbil;
  final int? perpanjangan;
  final double? rating;
  final DateTime? tenggatPenitipan;
  final Kategori? kategori;

  Produk({
    this.kodeProduk,
    this.idKategori,
    this.namaProduk,
    this.tanggalMasuk,
    this.tanggalAmbil,
    this.harga,
    this.statusProduk,
    this.deskripsi,
    this.berat,
    this.tglGaransi,
    this.batasAmbil,
    this.perpanjangan,
    this.rating,
    this.tenggatPenitipan,
    this.kategori,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      kodeProduk: json['kode_produk']?.toString(),
      idKategori: TransaksiPenjualan._parseInt(json['id_kategori']),
      namaProduk: json['nama_produk']?.toString(),
      tanggalMasuk: json['tanggal_masuk'] != null
          ? DateTime.tryParse(json['tanggal_masuk'].toString())
          : null,
      tanggalAmbil: json['tanggal_ambil'] != null
          ? DateTime.tryParse(json['tanggal_ambil'].toString())
          : null,
      harga: TransaksiPenjualan._parseDouble(json['harga_jual']) ??
          TransaksiPenjualan._parseDouble(json['harga']),
      statusProduk: json['status_produk']?.toString(),
      deskripsi: json['deskripsi']?.toString(),
      berat: TransaksiPenjualan._parseDouble(json['berat']),
      tglGaransi: json['tgl_garansi'] != null
          ? DateTime.tryParse(json['tgl_garansi'].toString())
          : null,
      batasAmbil: json['batas_ambil'] != null
          ? DateTime.tryParse(json['batas_ambil'].toString())
          : null,
      perpanjangan: TransaksiPenjualan._parseInt(json['perpanjangan']),
      rating: TransaksiPenjualan._parseDouble(json['rating']),
      tenggatPenitipan: json['tenggat_penitipan'] != null
          ? DateTime.tryParse(json['tenggat_penitipan'].toString())
          : null,
      kategori:
          json['kategori'] != null ? Kategori.fromJson(json['kategori']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode_produk': kodeProduk,
      'id_kategori': idKategori,
      'nama_produk': namaProduk,
      'tanggal_masuk': tanggalMasuk?.toIso8601String(),
      'tanggal_ambil': tanggalAmbil?.toIso8601String(),
      'harga_jual': harga,
      'status_produk': statusProduk,
      'deskripsi': deskripsi,
      'berat': berat,
      'tgl_garansi': tglGaransi?.toIso8601String(),
      'batas_ambil': batasAmbil?.toIso8601String(),
      'perpanjangan': perpanjangan,
      'rating': rating,
      'tenggat_penitipan': tenggatPenitipan?.toIso8601String(),
      'kategori': kategori?.toJson(),
    };
  }
}

class Alamat {
  final String? idAlamat;
  final String? idMember;
  final String? alamat;
  final String? kecamatan;
  final String? kelurahan;
  final String? kodePos;
  final String? noTelp;

  Alamat({
    this.idAlamat,
    this.idMember,
    this.alamat,
    this.kecamatan,
    this.kelurahan,
    this.kodePos,
    this.noTelp,
  });

  factory Alamat.fromJson(Map<String, dynamic> json) {
    return Alamat(
      idAlamat: json['id_alamat']?.toString(),
      idMember: json['id_member']?.toString() ?? json['id_pembeli']?.toString(),
      alamat: json['alamat']?.toString(),
      kecamatan: json['kecamatan']?.toString(),
      kelurahan: json['kelurahan']?.toString(),
      kodePos: json['kode_pos']?.toString(),
      noTelp: json['no_telp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_alamat': idAlamat,
      'id_member': idMember,
      'alamat': alamat,
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
      'kode_pos': kodePos,
      'no_telp': noTelp,
    };
  }
}

class Kategori {
  final int? idKategori;
  final String? namaKategori;

  Kategori({
    this.idKategori,
    this.namaKategori,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      idKategori: TransaksiPenjualan._parseInt(json['id_kategori']),
      namaKategori: json['nama_kategori']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kategori': idKategori,
      'nama_kategori': namaKategori,
    };
  }
}

class Pembeli {
  final String? idPembeli;
  final String? namaPembeli;
  final String? fotoProfilPembeli;
  final String? email;
  final String? usernamePembeli;
  final int? poinPembeli;
  final String? alamatPembeli;
  final String? fcmToken;

  Pembeli({
    this.idPembeli,
    this.namaPembeli,
    this.fotoProfilPembeli,
    this.email,
    this.usernamePembeli,
    this.poinPembeli,
    this.alamatPembeli,
    this.fcmToken,
  });

  factory Pembeli.fromJson(Map<String, dynamic> json) {
    return Pembeli(
      idPembeli: json['id_pembeli']?.toString(),
      namaPembeli: json['nama_pembeli']?.toString(),
      fotoProfilPembeli: json['fotoprofil_pembeli']?.toString(),
      email: json['email']?.toString(),
      usernamePembeli: json['username_pembeli']?.toString(),
      poinPembeli: TransaksiPenjualan._parseInt(json['poin_pembeli']),
      alamatPembeli: json['alamat_pembeli']?.toString(),
      fcmToken: json['fcm_token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pembeli': idPembeli,
      'nama_pembeli': namaPembeli,
      'fotoprofil_pembeli': fotoProfilPembeli,
      'email': email,
      'username_pembeli': usernamePembeli,
      'poin_pembeli': poinPembeli,
      'alamat_pembeli': alamatPembeli,
      'fcm_token': fcmToken,
    };
  }
}
