import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

/// Do not have a controller for a list of items? Or do not want to create one just because of
/// one time use, use [PaginationItemsStateHandler], it handles the state internally and
/// wraps above a [PaginatedItemsBuilder].
///
/// The [builder] provides the required arguments needed by the [PaginatedItemsBuilder].
class PaginationItemsStateHandler<T> extends StatefulWidget {
  /// Pass in a function that calls the API and returns a [PaginatedItemsResponse].
  final Future<PaginatedItemsResponse<T>?> Function(dynamic paginationKey)
      fetchPageData;

  /// Callback method that usually should return a [PaginatedItemsBuilder] and
  /// pass the [response] and [fetchPageData] params to the builder.
  final Widget Function(
    PaginatedItemsResponse<T>? response,
    Future<void> Function(
      bool reset,
      ItemsFetchScope itemsFetchScope,
    )
        fetchPageData,
  ) builder;

  /// Whether to switch all the cards to their respective loaders when [reset] is true,
  /// i.e. if the user pulls down to refresh, or no items were found...
  ///
  /// The callback value is the [ItemsFetchScope], which defines the action calling the
  /// fetch data function.
  ///
  /// The [reset] flag will be true only when the [itemsFetchScope] is either
  /// [ItemsFetchScope.noItemsRefresh] i.e. no items were found, and user
  /// clicked the refresh icon OR [ItemsFetchScope.pullDownToRefresh] i.e.
  /// the user wants to refresh the list contents with pull-down action.
  ///
  /// This callback will only be called if [reset] is true.
  ///
  /// By default, [showLoaderOnResetBuilder] is true only if [scope] is [ItemsFetchScope.noItemsRefresh].
  final bool Function(ItemsFetchScope itemsFetchScope)?
      showLoaderOnResetBuilder;

  const PaginationItemsStateHandler({
    Key? key,
    required this.fetchPageData,
    required this.builder,
    this.showLoaderOnResetBuilder,
  }) : super(key: key);

  @override
  State<PaginationItemsStateHandler<T>> createState() =>
      _PaginationItemsStateHandlerState<T>();
}

class _PaginationItemsStateHandlerState<T>
    extends State<PaginationItemsStateHandler<T>> {
  PaginatedItemsResponse<T>? _itemsResponse;

  Future<void> _update(bool reset, ItemsFetchScope scope) async {
    bool showLoaderOnReset = scope == ItemsFetchScope.noItemsRefresh;
    if (reset && widget.showLoaderOnResetBuilder != null) {
      showLoaderOnReset = widget.showLoaderOnResetBuilder!(scope);
    }

    // showLoaderOnReset only used if reset is true...
    if (reset && showLoaderOnReset) {
      _itemsResponse = null;
      setState(() {});
    }

    try {
      final res = await widget.fetchPageData(
        reset ? null : _itemsResponse?.paginationKey,
      );
      if (reset || _itemsResponse == null) {
        _itemsResponse = res;
      } else {
        _itemsResponse!.update(res);
      }
    } catch (error, stackTrace) {
      dev.log(
        '\nSomething went wrong.. Most probably the fetchPageData failed due to some error! Please handle any possible errors in the fetchPageData call.',
        name: 'PaginationItemsStateHandler<$T>',
        error: error,
        stackTrace: stackTrace,
      );
    }

    try {
      setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => widget.builder(_itemsResponse, _update);
}
