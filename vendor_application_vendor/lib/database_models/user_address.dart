
import 'package:json_annotation/json_annotation.dart';
import 'geolocation.dart';
part 'user_address.g.dart';

@JsonSerializable(explicitToJson: true)
class UserAddress{
  String houseNo ;
  String streetArea;
  String landmark;
  String description;
  String addressType;
  String pincode;
  Geolocation geolocation;
  String addressId ;
  String name ;
  String mobile ;

  UserAddress.custom({this.name , this.mobile , this.streetArea, this.landmark, this.description,
    this.addressType, this.pincode});



  UserAddress(this.houseNo, this.streetArea, this.landmark, this.description,
      this.addressType, this.pincode,this.geolocation , this.addressId , this.mobile , this.name );


  factory UserAddress.fromJson(Map<String,dynamic> data) => _$UserAddressFromJson(data);

  Map<String,dynamic> toJson() => _$UserAddressToJson(this);

}