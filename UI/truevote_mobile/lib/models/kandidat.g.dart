// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kandidat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Kandidat _$KandidatFromJson(Map<String, dynamic> json) => Kandidat(
  id: (json['id'] as num).toInt(),
  ime: json['ime'] as String?,
  prezime: json['prezime'] as String?,
  strankaId: (json['strankaId'] as num?)?.toInt(),
  izborId: (json['izborId'] as num?)?.toInt(),
  slika: json['slika'] as String?,
  izbor: json['izbor'] == null
      ? null
      : Izbor.fromJson(json['izbor'] as Map<String, dynamic>),
  stranka: json['stranka'] == null
      ? null
      : Stranka.fromJson(json['stranka'] as Map<String, dynamic>),
);

Map<String, dynamic> _$KandidatToJson(Kandidat instance) => <String, dynamic>{
  'id': instance.id,
  'ime': instance.ime,
  'prezime': instance.prezime,
  'strankaId': instance.strankaId,
  'izborId': instance.izborId,
  'slika': instance.slika,
  'izbor': instance.izbor,
  'stranka': instance.stranka,
};
