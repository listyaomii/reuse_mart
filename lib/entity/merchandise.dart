
class Merchandise {
  final int idMerch;
  final String namaMerch;
  final int poinTukar;
  final int stokMerch;

  Merchandise({
    required this.idMerch,
    required this.namaMerch,
    required this.poinTukar,
    required this.stokMerch,
  });

  factory Merchandise.fromJson(Map<String, dynamic> json) {
    return Merchandise(
      idMerch: json['id_merch'] as int,
      namaMerch: json['nama_merch'] as String,
      poinTukar: json['poin_tukar'] as int,
      stokMerch: json['stok_merch'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_merch': idMerch,
      'nama_merch': namaMerch,
      'poin_tukar': poinTukar,
      'stok_merch': stokMerch,
    };
  }
}