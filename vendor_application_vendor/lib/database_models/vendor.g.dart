// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vendor _$VendorFromJson(Map<String, dynamic> json) {
  return Vendor(
    json['vendorId'] as String,
    json['name'] as String,
    json['email'] as String,
    json['mobile'] as String,
    json['password'] as String,
    json['businessName'] as String,
    json['image'] as String,
  )
    ..shops = (json['shops'] as List)
        ?.map(
            (e) => e == null ? null : Shop.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..deliveryBoy = (json['deliveryBoy'] as List)
        ?.map((e) => e == null
            ? null
            : VendorDeliveryBoy.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
      'vendorId': instance.vendorId,
      'name': instance.name,
      'email': instance.email,
      'businessName': instance.businessName,
      'mobile': instance.mobile,
      'password': instance.password,
      'image': instance.image,
      'shops': instance.shops?.map((e) => e?.toJson())?.toList(),
      'deliveryBoy': instance.deliveryBoy?.map((e) => e?.toJson())?.toList(),
    };
