import 'package:json_annotation/json_annotation.dart';
import 'shop.dart' ;
import 'deliveryBoy.dart';

part 'vendor.g.dart';

@JsonSerializable(explicitToJson: true)
class Vendor{
  String vendorId;
  String name;
  String email ;
  String businessName;
  String mobile;
  String password;
  String image;
  List<Shop> shops;
  List<VendorDeliveryBoy> deliveryBoy;



  Vendor(this.vendorId,this.name,this.email,this.mobile,this.password,this.businessName,this.image);


  Vendor.full(this.vendorId, this.name, this.email, this.businessName,
      this.mobile, this.password, this.image, this.shops, this.deliveryBoy);

  factory Vendor.fromJson(Map<String,dynamic> data) => _$VendorFromJson(data);

  Map<String,dynamic> toJson() => _$VendorToJson(this);


}