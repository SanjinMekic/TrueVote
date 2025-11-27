import 'package:json_annotation/json_annotation.dart';
import 'package:truevote_desktop/models/kategorija.dart';
part 'pitanje.g.dart';

@JsonSerializable()
class Pitanje {
  int id;
  int? kategorijaId;
  String? pitanjeText;
  String? odgovorText;
  DateTime? datumKreiranja;
  Kategorija? kategorija;

  Pitanje({required this.id, this.kategorijaId, this.pitanjeText, this.odgovorText, this.datumKreiranja, this.kategorija});

  factory Pitanje.fromJson(Map<String, dynamic> json) =>
      _$PitanjeFromJson(json);
  Map<String, dynamic> toJson() => _$PitanjeToJson(this);
}
