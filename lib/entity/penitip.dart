class Penitip {
  final String idPenitip;
  final String? idPegawai;
  final String namaPenitip;
  final String? alamat;  // Tambahan field alamat
  final double saldoPenitip;
  final String email;
  final String usernamePenitip;
  final int poinPenitip;
  final double totalPenjualan;
  final String noIdentitas;
  final String? fotoKtp;

  Penitip({
    required this.idPenitip,
    this.idPegawai,
    required this.namaPenitip,
    this.alamat,
    required this.saldoPenitip,
    required this.email,
    required this.usernamePenitip,
    required this.poinPenitip,
    required this.totalPenjualan,
    required this.noIdentitas,
    this.fotoKtp,
  });

  factory Penitip.fromJson(Map<String, dynamic> json) {
    return Penitip(
      idPenitip: json['id_penitip'] ?? '',
      idPegawai: json['id_pegawai'],
      namaPenitip: json['nama_penitip'] ?? '',
      alamat: json['alamat'], // Tambahan field alamat
      saldoPenitip: (json['saldo_penitip'] ?? 0).toDouble(),
      email: json['email'] ?? '',
      usernamePenitip: json['username_penitip'] ?? '',
      poinPenitip: json['poin_penitip'] ?? 0,
      totalPenjualan: (json['total_penjualan'] ?? 0).toDouble(),
      noIdentitas: json['no_identitas'] ?? '',
      fotoKtp: json['foto_ktp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_penitip': idPenitip,
      'id_pegawai': idPegawai,
      'nama_penitip': namaPenitip,
      'alamat': alamat,
      'saldo_penitip': saldoPenitip,
      'email': email,
      'username_penitip': usernamePenitip,
      'poin_penitip': poinPenitip,
      'total_penjualan': totalPenjualan,
      'no_identitas': noIdentitas,
      'foto_ktp': fotoKtp,
    };
  }
}