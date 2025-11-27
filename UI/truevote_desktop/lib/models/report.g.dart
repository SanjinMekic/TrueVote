// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
  brojDrzava: (json['brojDrzava'] as num?)?.toInt(),
  brojGradova: (json['brojGradova'] as num?)?.toInt(),
  brojOpstina: (json['brojOpstina'] as num?)?.toInt(),
  brojStranaka: (json['brojStranaka'] as num?)?.toInt(),
  brojKorisnika: (json['brojKorisnika'] as num?)?.toInt(),
  brojBiraca: (json['brojBiraca'] as num?)?.toInt(),
  brojAdmina: (json['brojAdmina'] as num?)?.toInt(),
  brojKandidata: (json['brojKandidata'] as num?)?.toInt(),
  brojIzbora: (json['brojIzbora'] as num?)?.toInt(),
  brojFaqPitanja: (json['brojFaqPitanja'] as num?)?.toInt(),
);

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
  'brojDrzava': instance.brojDrzava,
  'brojGradova': instance.brojGradova,
  'brojOpstina': instance.brojOpstina,
  'brojStranaka': instance.brojStranaka,
  'brojKorisnika': instance.brojKorisnika,
  'brojBiraca': instance.brojBiraca,
  'brojAdmina': instance.brojAdmina,
  'brojKandidata': instance.brojKandidata,
  'brojIzbora': instance.brojIzbora,
  'brojFaqPitanja': instance.brojFaqPitanja,
};
