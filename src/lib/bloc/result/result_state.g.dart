// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResultStateImpl _$$ResultStateImplFromJson(Map<String, dynamic> json) =>
    _$ResultStateImpl(
      answer: json['answer'] as String,
      steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
      followUpsLeft: (json['followUpsLeft'] as num).toInt(),
      isSubmitting: json['isSubmitting'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$ResultStateImplToJson(_$ResultStateImpl instance) =>
    <String, dynamic>{
      'answer': instance.answer,
      'steps': instance.steps,
      'followUpsLeft': instance.followUpsLeft,
      'isSubmitting': instance.isSubmitting,
      'error': instance.error,
    };
