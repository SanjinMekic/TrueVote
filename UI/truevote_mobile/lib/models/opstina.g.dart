// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opstina.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Opstina _$OpstinaFromJson(Map<String, dynamic> json) => Opstina(
  id: (json['id'] as num).toInt(),
  naziv: json['naziv'] as String?,
  gradId: (json['gradId'] as num?)?.toInt(),
  grad: json['grad'] == null
      ? null
      : Grad.fromJson(json['grad'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OpstinaToJson(Opstina instance) => <String, dynamic>{
  'id': instance.id,
  'naziv': instance.naziv,
  'gradId': instance.gradId,
  'grad': instance.grad,
};
