class Pembeli {
  final String idPembeli; // Primary key, otomatis dibuat oleh Laravel
  final String namaPembeli;
  final String? fotoProfilPembeli;
  final String email;
  final String usernamePembeli;
  final String passwordPembeli; // Biasanya tidak dikembalikan, tapi disertakan untuk konsistensi
  final int poinPembeli;
  final String alamatPembeli;

  Pembeli({
    required this.idPembeli,
    required this.namaPembeli,
    this.fotoProfilPembeli,
    required this.email,
    required this.usernamePembeli,
    required this.passwordPembeli,
    required this.poinPembeli,
    required this.alamatPembeli,
  });

  factory Pembeli.fromJson(Map<String, dynamic> json) {
    return Pembeli(
      idPembeli: json['id_pembeli'] ?? '', // Asumsi id_pembeli dibuat otomatis
      namaPembeli: json['nama_pembeli'] ?? '',
      fotoProfilPembeli: json['fotoprofil_pembeli'],
      email: json['email'] ?? '',
      usernamePembeli: json['username_pembeli'] ?? '',
      passwordPembeli: json['password_pembeli'] ?? '', // Biasanya null dari backend
      poinPembeli: json['poin_pembeli'] ?? 0,
      alamatPembeli: json['alamat_pembeli'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pembeli': idPembeli,
      'nama_pembeli': namaPembeli,
      'fotoprofil_pembeli': fotoProfilPembeli,
      'email': email,
      'username_pembeli': usernamePembeli,
      'password_pembeli': passwordPembeli,
      'poin_pembeli': poinPembeli,
      'alamat_pembeli': alamatPembeli,
    };
  }
}