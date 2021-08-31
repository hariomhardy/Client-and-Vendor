// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAddress _$UserAddressFromJson(Map<String, dynamic> json) {
  return UserAddress(
    json['houseNo'] as String,
    json['streetArea'] as String,
    json['landmark'] as String,
    json['description'] as String,
    json['addressType'] as String,
    json['pincode'] as String,
    json['geolocation'] == null
        ? null
        : Geolocation.fromJson(json['geolocation'] as Map<String, dynamic>),
    json['addressId'] as String,
    json['mobile'] as String,
    json['name'] as String,
  );
}

Map<String, dynamic> _$UserAddressToJson(UserAddress instance) =>
    <String, dynamic>{
      'houseNo': instance.houseNo,
      'streetArea': instance.streetArea,
      'landmark': instance.landmark,
      'description': instance.description,
      'addressType': instance.addressType,
      'pincode': instance.pincode,
      'geolocation': instance.geolocation?.toJson(),
      'addressId': instance.addressId,
      'name': instance.name,
      'mobile': instance.mobile,
    };
