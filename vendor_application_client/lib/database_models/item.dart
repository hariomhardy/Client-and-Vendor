

import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item{
  String itemId;
  String productName;
  String productDescription;
  int quantity;
  int count;
  String quantityType;
  String image;
  double originalPrice;
  double discountPrice;
  String category;
  String subcategory;
  String shopId ;
  String vendorId ;
  List<String> trigram;

  Item.custom({this.vendorId , this.shopId , this.category , this.productName , this.productDescription , this.quantity ,
    this.quantityType , this.originalPrice , this.discountPrice }) ;

  Item.full(this.productName, this.productDescription, this.quantity,
      this.quantityType, this.image, this.originalPrice, this.discountPrice,
      this.category, this.subcategory , this.shopId , this.vendorId );


  Item(
      this.productName,
      this.productDescription,
      this.quantity,
      this.count,
      this.quantityType,
      this.image,
      this.originalPrice,
      this.category,
      this.subcategory ,
      this.shopId ,
      this.vendorId);

  factory Item.fromJson(Map<String,dynamic> data) => _$ItemFromJson(data);

  Map<String,dynamic> toJson() => _$ItemToJson(this);

}