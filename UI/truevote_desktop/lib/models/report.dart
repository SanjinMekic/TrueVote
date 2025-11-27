import 'package:json_annotation/json_annotation.dart';
part 'report.g.dart';

@JsonSerializable()
class Report {
  int? brojDrzava;
  int? brojGradova;
  int? brojOpstina;
  int? brojStranaka;
  int? brojKorisnika;
  int? brojBiraca;
  int? brojAdmina;
  int? brojKandidata;
  int? brojIzbora;
  int? brojFaqPitanja;

  Report({
    this.brojDrzava,
    this.brojGradova,
    this.brojOpstina,
    this.brojStranaka,
    this.brojKorisnika,
    this.brojBiraca,
    this.brojAdmina,
    this.brojKandidata,
    this.brojIzbora,
    this.brojFaqPitanja,
  });

  factory Report.fromJson(Map<String, dynamic> json) =>
      _$ReportFromJson(json);

  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
