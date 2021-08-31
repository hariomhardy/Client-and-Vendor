// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rating _$RatingFromJson(Map<String, dynamic> json) {
  return Rating(
    (json['punctuality'] as num)?.toDouble(),
    (json['quality'] as num)?.toDouble(),
    (json['behaviour'] as num)?.toDouble(),
    (json['satisfaction'] as num)?.toDouble(),
    (json['timelyCompletion'] as num)?.toDouble(),
  )
    ..count = json['count'] as int
    ..overallRating = (json['overallRating'] as num)?.toDouble();
}

Map<String, dynamic> _$RatingToJson(Rating instance) => <String, dynamic>{
      'punctuality': instance.punctuality,
      'quality': instance.quality,
      'behaviour': instance.behaviour,
      'satisfaction': instance.satisfaction,
      'timelyCompletion': instance.timelyCompletion,
      'count': instance.count,
      'overallRating': instance.overallRating,
    };
