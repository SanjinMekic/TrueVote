import 'package:json_annotation/json_annotation.dart';
import 'package:truevote_desktop/models/opstina.dart';
import 'package:truevote_desktop/models/uloga.dart';

part 'korisnik.g.dart';

@JsonSerializable()
class Korisnik {
  int id;
  String? ime;
  String? prezime;
  String? email;
  String? korisnickoIme;
  int? ulogaId;
  int? opstinaId;
  String? slika;
  String? pin;
  Opstina? opstina;
  Uloga? uloga;
  bool? sistemAdministrator;

  Korisnik({
    required this.id,
    this.ime,
    this.prezime,
    this.email,
    this.korisnickoIme,
    this.ulogaId,
    this.opstinaId,
    this.slika,
    this.pin,
    this.opstina,
    this.uloga,
    this.sistemAdministrator,
  });

  factory Korisnik.fromJson(Map<String, dynamic> json) =>
      _$KorisnikFromJson(json);

  Map<String, dynamic> toJson() => _$KorisnikToJson(this);
}
