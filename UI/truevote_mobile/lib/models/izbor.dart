import 'package:json_annotation/json_annotation.dart';
import 'package:truevote_mobile/models/tip_izbora.dart';

part 'izbor.g.dart';

@JsonSerializable()
class Izbor {
  int id;
  int? tipIzboraId;
  DateTime? datumPocetka;
  DateTime? datumKraja;
  String? status;
  TipIzbora? tipIzbora;

  Izbor({
    required this.id,
    this.tipIzboraId,
    this.datumPocetka,
    this.datumKraja,
    this.status,
    this.tipIzbora,
  });

  factory Izbor.fromJson(Map<String, dynamic> json) =>
      _$IzborFromJson(json);

  Map<String, dynamic> toJson() => _$IzborToJson(this);
}
