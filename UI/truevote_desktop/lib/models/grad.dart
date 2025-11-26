import 'package:json_annotation/json_annotation.dart';
import 'package:truevote_desktop/models/drzava.dart';

part 'grad.g.dart';

@JsonSerializable()
class Grad {
  int id;
  String? naziv;
  int? drzavaId;
  Drzava? drzava;

  Grad({required this.id, this.naziv, this.drzavaId, this.drzava});

  factory Grad.fromJson(Map<String, dynamic> json) => _$GradFromJson(json);
  Map<String, dynamic> toJson() => _$GradToJson(this);
}