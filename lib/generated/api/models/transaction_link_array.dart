// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import

import 'package:json_annotation/json_annotation.dart';

import 'meta.dart';
import 'page_link.dart';
import 'transaction_link_read.dart';

part 'transaction_link_array.g.dart';

@JsonSerializable()
class TransactionLinkArray {
  const TransactionLinkArray({
    required this.data,
    required this.meta,
    required this.links,
  });
  
  factory TransactionLinkArray.fromJson(Map<String, Object?> json) => _$TransactionLinkArrayFromJson(json);
  
  final List<TransactionLinkRead> data;
  final Meta meta;
  final PageLink links;

  Map<String, Object?> toJson() => _$TransactionLinkArrayToJson(this);
}
