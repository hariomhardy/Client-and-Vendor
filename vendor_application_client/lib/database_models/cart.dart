
import 'package:json_annotation/json_annotation.dart';
import 'item.dart';

part 'cart.g.dart';

@JsonSerializable(explicitToJson: true)
class Cart{
  String vendorId;
  String shopId;
  double originalPrice;
  double discountPrice;
  List<Item> items;

  Cart(this.vendorId, this.shopId, this.originalPrice, this.discountPrice,
      this.items);

  factory Cart.fromJson(Map<String,dynamic> data) => _$CartFromJson(data);

  Map<String,dynamic> toJson() => _$CartToJson(this);

}