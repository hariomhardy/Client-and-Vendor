// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    json['productName'] as String,
    json['productDescription'] as String,
    json['quantity'] as int,
    json['count'] as int,
    json['quantityType'] as String,
    json['image'] as String,
    (json['originalPrice'] as num)?.toDouble(),
    json['category'] as String,
    json['subcategory'] as String,
    json['shopId'] as String,
    json['vendorId'] as String,
  )
    ..itemId = json['itemId'] as String
    ..discountPrice = (json['discountPrice'] as num)?.toDouble()
    ..trigram = (json['trigram'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'itemId': instance.itemId,
      'productName': instance.productName,
      'productDescription': instance.productDescription,
      'quantity': instance.quantity,
      'count': instance.count,
      'quantityType': instance.quantityType,
      'image': instance.image,
      'originalPrice': instance.originalPrice,
      'discountPrice': instance.discountPrice,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'shopId': instance.shopId,
      'vendorId': instance.vendorId,
      'trigram': instance.trigram,
    };
