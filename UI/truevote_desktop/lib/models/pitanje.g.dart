// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pitanje.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pitanje _$PitanjeFromJson(Map<String, dynamic> json) => Pitanje(
  id: (json['id'] as num).toInt(),
  kategorijaId: (json['kategorijaId'] as num?)?.toInt(),
  pitanjeText: json['pitanjeText'] as String?,
  odgovorText: json['odgovorText'] as String?,
  datumKreiranja: json['datumKreiranja'] == null
      ? null
      : DateTime.parse(json['datumKreiranja'] as String),
  kategorija: json['kategorija'] == null
      ? null
      : Kategorija.fromJson(json['kategorija'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PitanjeToJson(Pitanje instance) => <String, dynamic>{
  'id': instance.id,
  'kategorijaId': instance.kategorijaId,
  'pitanjeText': instance.pitanjeText,
  'odgovorText': instance.odgovorText,
  'datumKreiranja': instance.datumKreiranja?.toIso8601String(),
  'kategorija': instance.kategorija,
};
