// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shop _$ShopFromJson(Map<String, dynamic> json) {
  return Shop(
    json['shopName'] as String,
    json['shopMobile'] as String,
    json['shopNumber'] as String,
    (json['minAmount'] as num)?.toDouble(),
    json['deliveryOptions'] as bool,
    json['address'] == null
        ? null
        : Address.fromJson(json['address'] as Map<String, dynamic>),
    json['openTime'],
    json['closeTime'],
  )
    ..shopId = json['shopId'] as String
    ..vendorId = json['vendorId'] as String
    ..image = json['image'] as String
    ..items = (json['items'] as List)
        ?.map(
            (e) => e == null ? null : Item.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..orders = (json['orders'] as List)?.map((e) => e as String)?.toList()
    ..ordersPending = (json['ordersPending'] as List)
        ?.map(
            (e) => e == null ? null : Order.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..rating = json['rating'] == null
        ? null
        : Rating.fromJson(json['rating'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ShopToJson(Shop instance) => <String, dynamic>{
      'shopId': instance.shopId,
      'vendorId': instance.vendorId,
      'shopName': instance.shopName,
      'shopMobile': instance.shopMobile,
      'shopNumber': instance.shopNumber,
      'minAmount': instance.minAmount,
      'deliveryOptions': instance.deliveryOptions,
      'openTime': instance.openTime,
      'closeTime': instance.closeTime,
      'image': instance.image,
      'address': instance.address?.toJson(),
      'items': instance.items?.map((e) => e?.toJson())?.toList(),
      'orders': instance.orders,
      'ordersPending':
          instance.ordersPending?.map((e) => e?.toJson())?.toList(),
      'rating': instance.rating?.toJson(),
    };
