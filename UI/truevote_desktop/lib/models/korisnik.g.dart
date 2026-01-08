// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korisnik.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Korisnik _$KorisnikFromJson(Map<String, dynamic> json) => Korisnik(
  id: (json['id'] as num).toInt(),
  ime: json['ime'] as String?,
  prezime: json['prezime'] as String?,
  email: json['email'] as String?,
  korisnickoIme: json['korisnickoIme'] as String?,
  ulogaId: (json['ulogaId'] as num?)?.toInt(),
  opstinaId: (json['opstinaId'] as num?)?.toInt(),
  slika: json['slika'] as String?,
  pin: json['pin'] as String?,
  opstina: json['opstina'] == null
      ? null
      : Opstina.fromJson(json['opstina'] as Map<String, dynamic>),
  uloga: json['uloga'] == null
      ? null
      : Uloga.fromJson(json['uloga'] as Map<String, dynamic>),
  sistemAdministrator: json['sistemAdministrator'] as bool?,
);

Map<String, dynamic> _$KorisnikToJson(Korisnik instance) => <String, dynamic>{
  'id': instance.id,
  'ime': instance.ime,
  'prezime': instance.prezime,
  'email': instance.email,
  'korisnickoIme': instance.korisnickoIme,
  'ulogaId': instance.ulogaId,
  'opstinaId': instance.opstinaId,
  'slika': instance.slika,
  'pin': instance.pin,
  'opstina': instance.opstina,
  'uloga': instance.uloga,
  'sistemAdministrator': instance.sistemAdministrator,
};
