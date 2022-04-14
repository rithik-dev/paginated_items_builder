import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

/// Do not have a controller for a list of items? Or do not want to create one just because of
/// one time use, use [PaginationItemsStateHandler], it handles the state internally and
/// wraps above a [PaginatedItemsBuilder].
///
/// The [builder] provides the required arguments needed by the [PaginatedItemsBuilder].
class PaginationItemsStateHandler<T> extends StatefulWidget {
  /// Pass in a function that calls the API and returns a [PaginatedItemsResponse].
  final Future<PaginatedItemsResponse<T>> Function(dynamic paginationKey)
      fetchPageData;

  /// Callback method that usually should return a [PaginatedItemsBuilder] and
  /// pass the [response] and [fetchPageData] params to the builder.
  final Widget Function(
    PaginatedItemsResponse<T>? response,
    Future<void> Function(bool reset) fetchPageData,
  ) builder;

  const PaginationItemsStateHandler({
    Key? key,
    required this.fetchPageData,
    required this.builder,
  }) : super(key: key);

  @override
  State<PaginationItemsStateHandler<T>> createState() =>
      _PaginationItemsStateHandlerState<T>();
}

class _PaginationItemsStateHandlerState<T>
    extends State<PaginationItemsStateHandler<T>> {
  PaginatedItemsResponse<T>? _itemsResponse;

  Future<void> _update(bool reset) async {
    // if something fails, the [errorWidgetBuilder] will be called in [PaginatedItemsBuilder].
    final res = await widget.fetchPageData(
      reset ? null : _itemsResponse?.paginationKey,
    );

    if (reset || _itemsResponse == null) {
      _itemsResponse = res;
    } else {
      _itemsResponse!.update(res);
    }

    try {
      setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => widget.builder(_itemsResponse, _update);
}
