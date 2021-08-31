// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliveryBoy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorDeliveryBoy _$VendorDeliveryBoyFromJson(Map<String, dynamic> json) {
  return VendorDeliveryBoy(
    json['deliveryBoyId'] as String,
    json['name'] as String,
    json['emailId'] as String,
    json['phoneNumber'] as String,
    json['password'] as String,
    json['address'] == null
        ? null
        : Address.fromJson(json['address'] as Map<String, dynamic>),
    json['image'] as String,
    (json['orders'] as List)?.map((e) => e as String)?.toList(),
  )..ordersPending = (json['ordersPending'] as List)
      ?.map((e) => e == null ? null : Order.fromJson(e as Map<String, dynamic>))
      ?.toList();
}

Map<String, dynamic> _$VendorDeliveryBoyToJson(VendorDeliveryBoy instance) =>
    <String, dynamic>{
      'deliveryBoyId': instance.deliveryBoyId,
      'name': instance.name,
      'emailId': instance.emailId,
      'phoneNumber': instance.phoneNumber,
      'password': instance.password,
      'address': instance.address?.toJson(),
      'image': instance.image,
      'orders': instance.orders,
      'ordersPending':
          instance.ordersPending?.map((e) => e?.toJson())?.toList(),
    };
