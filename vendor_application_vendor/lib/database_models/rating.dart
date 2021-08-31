import 'package:json_annotation/json_annotation.dart';

part 'rating.g.dart';

@JsonSerializable()
class Rating{
  double punctuality;
  double quality;
  double behaviour;
  double satisfaction;
  double timelyCompletion;
  int count ;
  double overallRating;

  Rating(this.punctuality,this.quality,this.behaviour,this.satisfaction,this.timelyCompletion);

  void rate(Rating rate){
    this.punctuality += rate.punctuality;
    this.quality += rate.quality;
    this.behaviour += rate.behaviour;
    this.satisfaction += rate.satisfaction;
    this.timelyCompletion += rate.timelyCompletion;
    this.count += 1;
    this.overallRating += punctuality+quality+behaviour+satisfaction+timelyCompletion;
  }


  factory Rating.fromJson(Map<String,dynamic> data) => _$RatingFromJson(data);

  Map<String,dynamic> toJson() => _$RatingToJson(this);
}