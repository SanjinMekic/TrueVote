import 'package:json_annotation/json_annotation.dart';
import 'package:truevote_desktop/models/opstina.dart';

part 'tip_izbora.g.dart';

@JsonSerializable()
class TipIzbora {
  int id;
  String? naziv;
  bool? dozvoljenoViseGlasova;
  int? maxBrojGlasova;
  int? opstinaId;
  Opstina? opstina;

  TipIzbora({
    required this.id,
    this.naziv,
    this.dozvoljenoViseGlasova,
    this.maxBrojGlasova,
    this.opstinaId,
    this.opstina,
  });

  factory TipIzbora.fromJson(Map<String, dynamic> json) =>
      _$TipIzboraFromJson(json);

  Map<String, dynamic> toJson() => _$TipIzboraToJson(this);
}
