// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Grad _$GradFromJson(Map<String, dynamic> json) => Grad(
  id: (json['id'] as num).toInt(),
  naziv: json['naziv'] as String?,
  drzavaId: (json['drzavaId'] as num?)?.toInt(),
  drzava: json['drzava'] == null
      ? null
      : Drzava.fromJson(json['drzava'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GradToJson(Grad instance) => <String, dynamic>{
  'id': instance.id,
  'naziv': instance.naziv,
  'drzavaId': instance.drzavaId,
  'drzava': instance.drzava,
};
