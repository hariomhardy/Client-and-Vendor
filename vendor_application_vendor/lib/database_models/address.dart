
import 'package:json_annotation/json_annotation.dart';
import 'geolocation.dart';

part 'address.g.dart';

@JsonSerializable(explicitToJson: true)
class Address{
  String streetArea;
  String landmark;
  String description;
  Geolocation location;

  Address.custom(this.description) ;

  Address(this.streetArea, this.landmark, this.description, this.location);

  factory Address.fromJson(Map<String,dynamic> data) => _$AddressFromJson(data);

  Map<String,dynamic> toJson() => _$AddressToJson(this);

}
