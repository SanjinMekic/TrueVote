import 'package:json_annotation/json_annotation.dart';

part 'stranka.g.dart';

@JsonSerializable()
class Stranka {
  int id;
  String? naziv;
  String? opis;
  DateTime? datumOsnivanja;
  String? sjediste;
  String? webUrl;
  String? logo;

  Stranka({
    required this.id,
    this.naziv,
    this.opis,
    this.datumOsnivanja,
    this.sjediste,
    this.webUrl,
    this.logo,
  });

  factory Stranka.fromJson(Map<String, dynamic> json) =>
      _$StrankaFromJson(json);

  Map<String, dynamic> toJson() => _$StrankaToJson(this);
}
