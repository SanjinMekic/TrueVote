import 'package:json_annotation/json_annotation.dart';
import 'package:truevote_desktop/models/grad.dart';

part 'opstina.g.dart';

@JsonSerializable()
class Opstina {
  int id;
  String? naziv;
  int? gradId;
  Grad? grad;

  Opstina({required this.id, this.naziv, this.gradId, this.grad});

  factory Opstina.fromJson(Map<String, dynamic> json) =>
      _$OpstinaFromJson(json);
  Map<String, dynamic> toJson() => _$OpstinaToJson(this);
}
