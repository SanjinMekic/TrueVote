// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glas.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Glas _$GlasFromJson(Map<String, dynamic> json) => Glas(
  id: (json['id'] as num).toInt(),
  korisnikId: (json['korisnikId'] as num?)?.toInt(),
  kandidatId: (json['kandidatId'] as num?)?.toInt(),
  vrijemeGlasanja: json['vrijemeGlasanja'] == null
      ? null
      : DateTime.parse(json['vrijemeGlasanja'] as String),
  kandidat: json['kandidat'] == null
      ? null
      : Kandidat.fromJson(json['kandidat'] as Map<String, dynamic>),
  korisnik: json['korisnik'] == null
      ? null
      : Korisnik.fromJson(json['korisnik'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GlasToJson(Glas instance) => <String, dynamic>{
  'id': instance.id,
  'korisnikId': instance.korisnikId,
  'kandidatId': instance.kandidatId,
  'vrijemeGlasanja': instance.vrijemeGlasanja?.toIso8601String(),
  'kandidat': instance.kandidat,
  'korisnik': instance.korisnik,
};
