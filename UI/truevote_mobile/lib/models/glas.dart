import 'package:json_annotation/json_annotation.dart';
import 'package:truevote_mobile/models/kandidat.dart';
import 'package:truevote_mobile/models/korisnik.dart';

part 'glas.g.dart';

@JsonSerializable()
class Glas {
  int id;
  int? korisnikId;
  int? kandidatId;
  DateTime? vrijemeGlasanja;
  Kandidat? kandidat;
  Korisnik? korisnik;

  Glas({
    required this.id,
    this.korisnikId,
    this.kandidatId,
    this.vrijemeGlasanja,
    this.kandidat,
    this.korisnik,
  });

  factory Glas.fromJson(Map<String, dynamic> json) => _$GlasFromJson(json);

  Map<String, dynamic> toJson() => _$GlasToJson(this);
}