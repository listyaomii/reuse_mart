class Pegawai {
  final String idPegawai;
  final String? idJabatan;
  final String namaPegawai;
  final String passwordPegawai;
  final String usernamePegawai;
  final String emailPegawai;
  final double saldoPegawai;
  final String? tglLahir;

  Pegawai({
    required this.idPegawai,
    this.idJabatan,
    required this.namaPegawai,
    required this.passwordPegawai,
    required this.usernamePegawai,
    required this.emailPegawai,
    required this.saldoPegawai,
    this.tglLahir,
  });

  factory Pegawai.fromJson(Map<String, dynamic> json) {
    return Pegawai(
      idPegawai: (json['id_pegawai'] ?? '').toString(),
      idJabatan: json['id_jabatan']?.toString(),
      namaPegawai: json['nama_pegawai'] ?? '',
      passwordPegawai: json['password_pegawai'] ?? '',
      usernamePegawai: json['username_pegawai'] ?? '',
      emailPegawai: json['email_pegawai'] ?? '',
      saldoPegawai: double.tryParse(json['saldo_pegawai'].toString()) ?? 0.0,
      tglLahir: json['tgl_lahir']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pegawai': idPegawai,
      'id_jabatan': idJabatan,
      'nama_pegawai': namaPegawai,
      'password_pegawai': passwordPegawai,
      'username_pegawai': usernamePegawai,
      'email_pegawai': emailPegawai,
      'saldo_pegawai': saldoPegawai,
      'tgl_lahir': tglLahir,
    };
  }
}
