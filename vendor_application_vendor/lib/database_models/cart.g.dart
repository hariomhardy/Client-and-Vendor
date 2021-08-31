// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cart _$CartFromJson(Map<String, dynamic> json) {
  return Cart(
    json['vendorId'] as String,
    json['shopId'] as String,
    (json['originalPrice'] as num)?.toDouble(),
    (json['discountPrice'] as num)?.toDouble(),
    (json['items'] as List)
        ?.map(
            (e) => e == null ? null : Item.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CartToJson(Cart instance) => <String, dynamic>{
      'vendorId': instance.vendorId,
      'shopId': instance.shopId,
      'originalPrice': instance.originalPrice,
      'discountPrice': instance.discountPrice,
      'items': instance.items?.map((e) => e?.toJson())?.toList(),
    };
