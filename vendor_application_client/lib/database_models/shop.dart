
import 'package:json_annotation/json_annotation.dart';
import 'address.dart';
import 'item.dart';
import 'order.dart';
import 'rating.dart';

part 'shop.g.dart';

@JsonSerializable(explicitToJson: true)
class Shop{
  String shopId;
  String vendorId;
  String shopName;
  String shopMobile;
  String shopNumber;
  double minAmount;
  bool deliveryOptions;
  var openTime;
  var closeTime;
  String image;
  Address address;
  List<Item> items;
  List<String> orders;   // Only store order id
  List<Order> ordersPending;
  Rating rating;


  Shop(this.shopName, this.shopMobile, this.shopNumber, this.minAmount, this.deliveryOptions, this.address, this.openTime,this.closeTime );

  Shop.withVendor(this.vendorId,this.shopName, this.shopMobile, this.shopNumber, this.minAmount, this.deliveryOptions, this.address, this.openTime,this.closeTime );

  Shop.full(this.shopId, this.shopName, this.shopMobile, this.shopNumber, this.minAmount, this.deliveryOptions,
      this.openTime, this.closeTime, this.image);



  factory Shop.fromJson(Map<String,dynamic> data) => _$ShopFromJson(data);

  Map<String,dynamic> toJson() => _$ShopToJson(this);
}