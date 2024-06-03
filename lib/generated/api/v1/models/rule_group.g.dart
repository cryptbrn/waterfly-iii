// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleGroup _$RuleGroupFromJson(Map<String, dynamic> json) => RuleGroup(
      title: json['title'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      description: json['description'] as String?,
      order: (json['order'] as num?)?.toInt(),
      active: json['active'] as bool?,
    );

Map<String, dynamic> _$RuleGroupToJson(RuleGroup instance) => <String, dynamic>{
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'order': instance.order,
      'active': instance.active,
    };
