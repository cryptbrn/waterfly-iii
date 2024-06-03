// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piggy_bank.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PiggyBank _$PiggyBankFromJson(Map<String, dynamic> json) => PiggyBank(
      accountId: json['account_id'] as String,
      name: json['name'] as String,
      targetAmount: json['target_amount'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      accountName: json['account_name'] as String?,
      currencyId: json['currency_id'] as String?,
      currencyCode: json['currency_code'] as String?,
      currencySymbol: json['currency_symbol'] as String?,
      currencyDecimalPlaces: (json['currency_decimal_places'] as num?)?.toInt(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      currentAmount: json['current_amount'] as String?,
      leftToSave: json['left_to_save'] as String?,
      savePerMonth: json['save_per_month'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      targetDate: json['target_date'] == null
          ? null
          : DateTime.parse(json['target_date'] as String),
      order: (json['order'] as num?)?.toInt(),
      active: json['active'] as bool?,
      notes: json['notes'] as String?,
      objectGroupId: json['object_group_id'] as String?,
      objectGroupOrder: (json['object_group_order'] as num?)?.toInt(),
      objectGroupTitle: json['object_group_title'] as String?,
    );

Map<String, dynamic> _$PiggyBankToJson(PiggyBank instance) => <String, dynamic>{
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'account_id': instance.accountId,
      'account_name': instance.accountName,
      'name': instance.name,
      'currency_id': instance.currencyId,
      'currency_code': instance.currencyCode,
      'currency_symbol': instance.currencySymbol,
      'currency_decimal_places': instance.currencyDecimalPlaces,
      'target_amount': instance.targetAmount,
      'percentage': instance.percentage,
      'current_amount': instance.currentAmount,
      'left_to_save': instance.leftToSave,
      'save_per_month': instance.savePerMonth,
      'start_date': instance.startDate?.toIso8601String(),
      'target_date': instance.targetDate?.toIso8601String(),
      'order': instance.order,
      'active': instance.active,
      'notes': instance.notes,
      'object_group_id': instance.objectGroupId,
      'object_group_order': instance.objectGroupOrder,
      'object_group_title': instance.objectGroupTitle,
    };
