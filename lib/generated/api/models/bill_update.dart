// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import

import 'package:json_annotation/json_annotation.dart';

import 'bill_repeat_frequency.dart';

part 'bill_update.g.dart';

@JsonSerializable()
class BillUpdate {
  const BillUpdate({
    required this.currencyId,
    required this.currencyCode,
    required this.name,
    required this.amountMin,
    required this.amountMax,
    required this.date,
    required this.endDate,
    required this.extensionDate,
    required this.repeatFreq,
    required this.skip,
    required this.active,
    required this.notes,
    required this.objectGroupId,
    required this.objectGroupTitle,
  });
  
  factory BillUpdate.fromJson(Map<String, Object?> json) => _$BillUpdateFromJson(json);
  
  /// Use either currency_id or currency_code
  @JsonKey(name: 'currency_id')
  final String currencyId;

  /// Use either currency_id or currency_code
  @JsonKey(name: 'currency_code')
  final String currencyCode;
  final String name;
  @JsonKey(name: 'amount_min')
  final String amountMin;
  @JsonKey(name: 'amount_max')
  final String amountMax;
  final DateTime date;

  /// The date after which this bill is no longer valid or applicable
  @JsonKey(name: 'end_date')
  final DateTime endDate;

  /// The date before which the bill must be renewed (or cancelled)
  @JsonKey(name: 'extension_date')
  final DateTime extensionDate;
  @JsonKey(name: 'repeat_freq')
  final BillRepeatFrequency repeatFreq;

  /// How often the bill must be skipped. 1 means a bi-monthly bill.
  final int skip;

  /// If the bill is active.
  final bool active;
  final String? notes;

  /// The group ID of the group this object is part of. NULL if no group.
  @JsonKey(name: 'object_group_id')
  final String? objectGroupId;

  /// The name of the group. NULL if no group.
  @JsonKey(name: 'object_group_title')
  final String? objectGroupTitle;

  Map<String, Object?> toJson() => _$BillUpdateToJson(this);
}
