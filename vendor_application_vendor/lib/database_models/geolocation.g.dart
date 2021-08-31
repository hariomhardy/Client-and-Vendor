// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geolocation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Geolocation _$GeolocationFromJson(Map<String, dynamic> json) {
  return Geolocation(
    json['lat'] as String,
    json['long'] as String,
  );
}

Map<String, dynamic> _$GeolocationToJson(Geolocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'long': instance.long,
    };
