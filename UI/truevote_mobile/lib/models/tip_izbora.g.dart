// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_izbora.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TipIzbora _$TipIzboraFromJson(Map<String, dynamic> json) => TipIzbora(
  id: (json['id'] as num).toInt(),
  naziv: json['naziv'] as String?,
  dozvoljenoViseGlasova: json['dozvoljenoViseGlasova'] as bool?,
  maxBrojGlasova: (json['maxBrojGlasova'] as num?)?.toInt(),
  opstinaId: (json['opstinaId'] as num?)?.toInt(),
  opstina: json['opstina'] == null
      ? null
      : Opstina.fromJson(json['opstina'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TipIzboraToJson(TipIzbora instance) => <String, dynamic>{
  'id': instance.id,
  'naziv': instance.naziv,
  'dozvoljenoViseGlasova': instance.dozvoljenoViseGlasova,
  'maxBrojGlasova': instance.maxBrojGlasova,
  'opstinaId': instance.opstinaId,
  'opstina': instance.opstina,
};
