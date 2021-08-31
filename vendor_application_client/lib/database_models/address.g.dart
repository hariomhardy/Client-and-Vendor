// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) {
  return Address(
    json['streetArea'] as String,
    json['landmark'] as String,
    json['description'] as String,
    json['location'] == null
        ? null
        : Geolocation.fromJson(json['location'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'streetArea': instance.streetArea,
      'landmark': instance.landmark,
      'description': instance.description,
      'location': instance.location?.toJson(),
    };
