// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'izbor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Izbor _$IzborFromJson(Map<String, dynamic> json) => Izbor(
  id: (json['id'] as num).toInt(),
  tipIzboraId: (json['tipIzboraId'] as num?)?.toInt(),
  datumPocetka: json['datumPocetka'] == null
      ? null
      : DateTime.parse(json['datumPocetka'] as String),
  datumKraja: json['datumKraja'] == null
      ? null
      : DateTime.parse(json['datumKraja'] as String),
  status: json['status'] as String?,
  tipIzbora: json['tipIzbora'] == null
      ? null
      : TipIzbora.fromJson(json['tipIzbora'] as Map<String, dynamic>),
);

Map<String, dynamic> _$IzborToJson(Izbor instance) => <String, dynamic>{
  'id': instance.id,
  'tipIzboraId': instance.tipIzboraId,
  'datumPocetka': instance.datumPocetka?.toIso8601String(),
  'datumKraja': instance.datumKraja?.toIso8601String(),
  'status': instance.status,
  'tipIzbora': instance.tipIzbora,
};
