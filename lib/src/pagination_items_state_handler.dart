import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

/// Do not have a controller for a list of items? Or do not want to create one just because of
/// one time use, use [PaginationItemsStateHandler], it handles the state internally and
/// wraps above a [PaginatedItemsBuilder].
///
/// The [itemsBuilder] provides the required arguments needed by the [PaginatedItemsBuilder].
class PaginationItemsStateHandler<T> extends StatefulWidget {
  /// Pass in a function that calls the API and returns a [PaginatedItemsResponse].
  final Future<PaginatedItemsResponse<T>?> Function(String? paginationKey)
      pageFetchData;

  /// Callback method that usually should return a [PaginatedItemsBuilder] and
  /// pass the [response] and [fetchPageData] params to the builder.
  final Widget Function(
    PaginatedItemsResponse<T>? response,
    Future<void> Function(bool) fetchPageData,
  ) itemsBuilder;

  const PaginationItemsStateHandler({
    Key? key,
    required this.pageFetchData,
    required this.itemsBuilder,
  }) : super(key: key);

  @override
  State<PaginationItemsStateHandler<T>> createState() =>
      _PaginationItemsStateHandlerState<T>();
}

class _PaginationItemsStateHandlerState<T>
    extends State<PaginationItemsStateHandler<T>> {
  PaginatedItemsResponse<T>? itemsResponse;

  Future<void> _update(bool reset) async {
    if (reset) {
      itemsResponse = null;
      setState(() {});
    }

    try {
      final res = await widget.pageFetchData(itemsResponse?.paginationKey);
      if (itemsResponse == null) {
        itemsResponse = res;
      } else {
        itemsResponse!.update(res);
      }
    } catch (_) {}

    try {
      setState(() {});
    } catch (_) {}
  }

  @override
  void initState() {
    _update(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.itemsBuilder(itemsResponse, _update);
  }
}
