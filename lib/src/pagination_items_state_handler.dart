import 'package:flutter/material.dart';
import 'package:paginated_items_builder/src/models/paginated_items_response.dart';

class PaginationItemsStateHandler<T> extends StatefulWidget {
  static const id = 'PaginationItemsStateHandler';

  final Future<PaginatedItemsResponse<T>?> Function(String? paginationKey) pageFetchData;
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
