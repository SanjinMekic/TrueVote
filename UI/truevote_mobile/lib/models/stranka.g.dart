// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stranka.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stranka _$StrankaFromJson(Map<String, dynamic> json) => Stranka(
  id: (json['id'] as num).toInt(),
  naziv: json['naziv'] as String?,
  opis: json['opis'] as String?,
  datumOsnivanja: json['datumOsnivanja'] == null
      ? null
      : DateTime.parse(json['datumOsnivanja'] as String),
  brojClanova: (json['brojClanova'] as num?)?.toInt(),
  sjediste: json['sjediste'] as String?,
  webUrl: json['webUrl'] as String?,
  logo: json['logo'] as String?,
);

Map<String, dynamic> _$StrankaToJson(Stranka instance) => <String, dynamic>{
  'id': instance.id,
  'naziv': instance.naziv,
  'opis': instance.opis,
  'datumOsnivanja': instance.datumOsnivanja?.toIso8601String(),
  'brojClanova': instance.brojClanova,
  'sjediste': instance.sjediste,
  'webUrl': instance.webUrl,
  'logo': instance.logo,
};
