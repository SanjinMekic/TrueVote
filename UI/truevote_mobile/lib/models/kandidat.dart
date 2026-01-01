import 'package:json_annotation/json_annotation.dart';
import 'package:truevote_mobile/models/izbor.dart';
import 'package:truevote_mobile/models/stranka.dart';

part 'kandidat.g.dart';

@JsonSerializable()
class Kandidat {
  int id;
  String? ime;
  String? prezime;
  int? strankaId;
  int? izborId;
  String? slika;
  Izbor? izbor;
  Stranka? stranka;

  Kandidat({
    required this.id,
    this.ime,
    this.prezime,
    this.strankaId,
    this.izborId,
    this.slika,
    this.izbor,
    this.stranka,
  });

  factory Kandidat.fromJson(Map<String, dynamic> json) =>
      _$KandidatFromJson(json);

  Map<String, dynamic> toJson() => _$KandidatToJson(this);
}
