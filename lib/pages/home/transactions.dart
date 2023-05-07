import 'dart:async';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:chopper/chopper.dart' show Response;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:waterflyiii/auth.dart';
import 'package:waterflyiii/extensions.dart';
import 'package:waterflyiii/generated/swagger_fireflyiii_api/firefly_iii.swagger.dart';
import 'package:waterflyiii/pages/home.dart';
import 'package:waterflyiii/pages/home/transactions/filter.dart';
import 'package:waterflyiii/pages/transaction.dart';
import 'package:waterflyiii/pages/transaction/delete.dart';

class HomeTransactions extends StatefulWidget {
  const HomeTransactions({Key? key, this.accountId}) : super(key: key);

  final String? accountId;

  @override
  State<HomeTransactions> createState() => _HomeTransactionsState();
}

class _HomeTransactionsState extends State<HomeTransactions>
    with AutomaticKeepAliveClientMixin {
  final int _numberOfPostsPerRequest = 50;

  final PagingController<int, TransactionRead> _pagingController =
      PagingController<int, TransactionRead>(
    firstPageKey: 0,
    invisibleItemsThreshold: 20,
  );

  DateTime? _lastDate;

  final TransactionFilters _filters = TransactionFilters();

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((int pageKey) {
      _fetchPage(pageKey);
    });

    // Only add button when in own tab
    if (widget.accountId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PageActions>().set(
          widget.key!,
          <Widget>[
            ChangeNotifierProvider<TransactionFilters>.value(
              value: _filters,
              builder: (BuildContext context, _) => IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                selectedIcon: Icon(Icons.filter_alt,
                    color: Theme.of(context).colorScheme.primary),
                isSelected: context.watch<TransactionFilters>().hasFilters,
                tooltip: S.of(context).homeTransactionsActionFilter,
                onPressed: () async {
                  TransactionFilters oldFilters = _filters.copyWith();
                  bool? ok = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => FilterDialog(
                      // passed by reference -> auto updated
                      filters: _filters,
                    ),
                  );
                  if (ok == null || !ok) {
                    return;
                  }
                  if (oldFilters == _filters) {
                    return;
                  }
                  _filters.updateFilters();
                  _pagingController.refresh();
                },
              ),
            ),
          ],
        );
      });
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();

    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final FireflyIii api = context.read<FireflyService>().api;
      late Future<Response<TransactionArray>> searchFunc;
      if (_filters.hasFilters) {
        String query = _filters.text ?? "";
        if (_filters.account != null) {
          query = "account_id:${_filters.account!.id} $query";
        }
        if (_filters.currency != null) {
          query = "currency_is:${_filters.currency!.attributes.code} $query";
        }
        if (_filters.category != null) {
          query =
              "category_is:\"${_filters.category!.attributes.name}\" $query";
        }
        if (_filters.budget != null) {
          query = "budget_is:\"${_filters.budget!.attributes.name}\" $query";
        }
        debugPrint("Search query: $query");
        searchFunc = api.v1SearchTransactionsGet(
          query: query,
          page: pageKey,
        );
      } else {
        searchFunc = (widget.accountId != null || _filters.account != null)
            ? api.v1AccountsIdTransactionsGet(
                id: widget.accountId ?? _filters.account!.id,
                page: pageKey,
                end: DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal()))
            : api.v1TransactionsGet(
                page: pageKey,
                end: DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal()),
              );
      }
      final Response<TransactionArray> response = await searchFunc;
      if (!response.isSuccessful || response.body == null) {
        if (context.mounted) {
          throw Exception(
            S
                .of(context)
                .errorAPIInvalidResponse(response.error?.toString() ?? ""),
          );
        } else {
          throw Exception(
            "[nocontext] Invalid API response: ${response.error}",
          );
        }
      }
      final List<TransactionRead> transactionList = response.body!.data;
      final bool isLastPage = transactionList.length < _numberOfPostsPerRequest;
      if (isLastPage) {
        _pagingController.appendLastPage(transactionList);
      } else {
        final int nextPageKey = pageKey + 1;
        _pagingController.appendPage(transactionList, nextPageKey);
      }
    } catch (e) {
      debugPrint("error --> $e");
      _pagingController.error = e;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    debugPrint("home_transactions build()");
    super.build(context);

    return RefreshIndicator(
      onRefresh: () => Future<void>.sync(() => _pagingController.refresh()),
      child: PagedListView<int, TransactionRead>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<TransactionRead>(
          itemBuilder: transactionRowBuilder,
        ),
        //itemExtent: 80,
      ),
    );
  }

  Widget transactionRowBuilder(
    BuildContext context,
    TransactionRead item,
    int index,
  ) {
    List<TransactionSplit> transactions = item.attributes.transactions;
    if (transactions.isEmpty) {
      return Text(S.of(context).homeTransactionsEmpty);
    }
    String category = "";
    int categories = 0;
    String notes = "";
    bool hasAttachments = false;
    double amount = 0.0;
    final Map<String, double> foreignAmounts = <String, double>{};
    final Map<String, CurrencyRead> foreignCurrencies =
        <String, CurrencyRead>{};
    String foreignText = "";
    String sourceName = "";
    String destinationName = "";
    late bool reconciled;
    for (TransactionSplit trans in transactions) {
      if (trans.categoryName?.isNotEmpty ?? false) {
        categories++;
        if (category.isEmpty) {
          category = trans.categoryName!;
        }
      }
      if (trans.notes?.isNotEmpty ?? false) {
        if (notes.isNotEmpty) {
          notes += "\n";
        }
        notes += trans.notes!.trim();
      }
      if (trans.hasAttachments ?? false) {
        hasAttachments = true;
      }
      amount += double.parse(trans.amount);
      if (trans.foreignAmount?.isNotEmpty ?? false) {
        final double amount = double.parse(trans.foreignAmount!);
        final String foreignSymbol =
            trans.foreignCurrencySymbol ?? trans.foreignCurrencyCode ?? "";
        if (amount != 0 && foreignSymbol.isNotEmpty) {
          foreignAmounts[foreignSymbol] =
              foreignAmounts[foreignSymbol] ?? 0 + amount;
          foreignCurrencies[foreignSymbol] = CurrencyRead(
            id: trans.foreignCurrencyId ?? "0",
            type: "currencies",
            attributes: Currency(
              code: trans.foreignCurrencyCode ?? "",
              name: "",
              symbol: trans.foreignCurrencySymbol ?? "",
              decimalPlaces: trans.foreignCurrencyDecimalPlaces,
            ),
          );
        }
      }
      if (sourceName == "") {
        sourceName = trans.sourceName!;
      } else if (sourceName != trans.sourceName!) {
        sourceName = S.of(context).generalMultiple;
      }
      if (destinationName == "") {
        destinationName = trans.destinationName!;
      } else if (destinationName != trans.destinationName!) {
        destinationName = S.of(context).generalMultiple;
      }
    }
    if (categories > 1) {
      category = S.of(context).homeTransactionsMultipleCategories(categories);
    }

    // Title
    late String title;
    if (item.attributes.groupTitle?.isNotEmpty ?? false) {
      title = item.attributes.groupTitle!;
    } else {
      title = transactions.first.description;
    }
    // Subtitle
    List<InlineSpan> subtitle = <InlineSpan>[];
    if (hasAttachments) {
      subtitle.add(const WidgetSpan(
        baseline: TextBaseline.ideographic,
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: EdgeInsets.only(right: 2),
          child: Icon(Icons.attachment),
        ),
      ));
    }
    if (transactions.first.type == TransactionTypeProperty.transfer) {
      subtitle.add(
        TextSpan(text: "(${S.of(context).transactionTypeTransfer}) "),
      );
    }
    subtitle.add(TextSpan(
      text: (transactions.first.type == TransactionTypeProperty.withdrawal)
          ? destinationName
          : sourceName,
    ));
    subtitle.add(const TextSpan(text: "\n"));
    if (category.isNotEmpty) {
      subtitle.add(TextSpan(
        text: category,
        style: const TextStyle(fontStyle: FontStyle.italic),
      ));
    }
    if (notes.isNotEmpty) {
      subtitle.add(
        TextSpan(
          text: "\n$notes",
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    reconciled = transactions.first.reconciled ?? false;
    final CurrencyRead currency = CurrencyRead(
      id: transactions.first.currencyId ?? "0",
      type: "currencies",
      attributes: Currency(
        code: transactions.first.currencyCode ?? "",
        name: transactions.first.currencyName ?? "",
        symbol: transactions.first.currencySymbol ?? "",
        decimalPlaces: transactions.first.currencyDecimalPlaces,
      ),
    );
    if (foreignAmounts.isNotEmpty) {
      foreignAmounts.forEach((String cur, double amount) {
        if (foreignCurrencies.containsKey(cur)) {
          foreignText += "${foreignCurrencies[cur]!.fmt(amount)} ";
        }
      });
      foreignText += " ";
    }

    Widget transactionWidget = OpenContainer(
      openBuilder: (BuildContext context, Function closedContainer) =>
          TransactionPage(transaction: item),
      openColor: Theme.of(context).cardColor,
      closedColor: Theme.of(context).cardColor,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      closedElevation: 0,
      closedBuilder: (BuildContext context, Function openContainer) =>
          GestureDetector(
        onLongPressStart: (LongPressStartDetails details) async {
          final Size screenSize = MediaQuery.of(context).size;
          final Offset offset = details.globalPosition;
          HapticFeedback.vibrate();
          final Function? func = await showMenu<Function>(
            context: context,
            position: RelativeRect.fromLTRB(
              offset.dx,
              offset.dy,
              screenSize.width - offset.dx,
              screenSize.height - offset.dy,
            ),
            items: <PopupMenuEntry<Function>>[
              PopupMenuItem<Function>(
                value: () async {
                  bool? ok = await Navigator.push(
                    context,
                    MaterialPageRoute<bool>(
                      builder: (BuildContext context) => TransactionPage(
                        transaction: item,
                        clone: true,
                      ),
                    ),
                  );
                  if (ok ?? false) {
                    _pagingController.refresh();
                  }
                },
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.copy),
                    const SizedBox(width: 12),
                    Text(S.of(context).transactionDuplicate),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<Function>(
                value: () async {
                  final FireflyIii api = context.read<FireflyService>().api;
                  bool? ok = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) =>
                        const DeletionConfirmDialog(),
                  );
                  if (!(ok ?? false)) {
                    return;
                  }

                  await api.v1TransactionsIdDelete(
                    id: item.id,
                  );
                  _pagingController.refresh();
                },
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.delete),
                    const SizedBox(width: 12),
                    Text(MaterialLocalizations.of(context).deleteButtonTooltip),
                  ],
                ),
              ),
            ],
            clipBehavior: Clip.hardEdge,
          );
          if (func == null) {
            return;
          }
          func();
        },
        child: ListTile(
          leading: CircleAvatar(
            foregroundColor: Colors.white,
            backgroundColor: transactions.first.type.color,
            child: Icon(transactions.first.type.icon),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: RichText(
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: subtitle,
            ),
          ),
          isThreeLine: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          trailing: RichText(
            textAlign: TextAlign.end,
            maxLines: 2,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: <InlineSpan>[
                if (foreignText.isNotEmpty)
                  TextSpan(
                    text: foreignText,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.blue,
                        ),
                  ),
                TextSpan(
                  text: currency.fmt(amount),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: transactions.first.type.color,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures()
                    ],
                  ),
                ),
                const TextSpan(text: "\n"),
                if (reconciled)
                  const WidgetSpan(
                    baseline: TextBaseline.ideographic,
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: Icon(Icons.check),
                    ),
                  ),
                TextSpan(
                  text: (transactions.first.type ==
                          TransactionTypeProperty.deposit)
                      ? destinationName
                      : sourceName,
                ),
              ],
            ),
          ),
          onTap: () => openContainer(),
        ),
      ),
      onClosed: (bool? refresh) {
        if (refresh ?? false == true) {
          _pagingController.refresh();
        }
      },
    );

    // Date
    DateTime date = transactions.first.date.toLocal();
    // Show Date Banner when:
    // 1. _lastDate is not set (= first element)
    // 2. _lastDate has a different day than current date (= date changed)
    // 3. _lastDate day is older than current date day. As the list is sorted by
    //    time, this should not happen, and means _lastDate just wasn't properly
    //    cleared
    if (_lastDate == null ||
        _lastDate!.clearTime() != date.clearTime() ||
        _lastDate!.clearTime().isBefore(date.clearTime())) {
      // Add date row
      transactionWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
            child: Text(
              DateFormat.yMd().format(date),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          transactionWidget,
        ],
      );
      _lastDate = date;
    }

    return transactionWidget;
  }
}
