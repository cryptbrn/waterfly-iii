// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import

import 'package:json_annotation/json_annotation.dart';

part 'budget_limit_v2.g.dart';

@JsonSerializable()
class BudgetLimitV2 {
  const BudgetLimitV2({
    required this.start,
    required this.end,
    required this.budgetId,
    required this.amount,
    this.createdAt,
    this.updatedAt,
    this.currencyId,
    this.currencyCode,
    this.currencyName,
    this.currencySymbol,
    this.currencyDecimalPlaces,
    this.period,
  });

  factory BudgetLimitV2.fromJson(Map<String, Object?> json) =>
      _$BudgetLimitV2FromJson(json);

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Start date of the budget limit.
  final DateTime start;

  /// End date of the budget limit.
  final DateTime end;

  /// Use either currency_id or currency_code. Defaults to the user's default currency.
  @JsonKey(name: 'currency_id')
  final String? currencyId;

  /// Use either currency_id or currency_code. Defaults to the user's default currency.
  @JsonKey(name: 'currency_code')
  final String? currencyCode;
  @JsonKey(name: 'currency_name')
  final String? currencyName;
  @JsonKey(name: 'currency_symbol')
  final String? currencySymbol;
  @JsonKey(name: 'currency_decimal_places')
  final int? currencyDecimalPlaces;

  /// The budget ID of the associated budget.
  @JsonKey(name: 'budget_id')
  final String budgetId;

  /// Period of the budget limit. Only used when auto-generated by auto-budget.
  final String? period;
  final String amount;

  Map<String, Object?> toJson() => _$BudgetLimitV2ToJson(this);
}
