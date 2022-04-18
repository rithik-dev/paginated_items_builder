import 'paginated_items_builder.dart';

/// Defines the scope from which [PaginatedItemsBuilder.fetchPageData]
/// in [PaginatedItemsBuilder] was called.
enum ItemsFetchScope {
  /// On user's pull down to refresh.
  ///
  /// Triggers only if [PaginatedItemsBuilder.disableRefreshIndicator] is false.
  pullDownToRefresh,

  /// If no items are present in the list.
  noItemsRefresh,

  /// When the data was initially being loaded.
  initialLoad,

  /// When more data to load was requested.
  /// Will only be triggered if pagination is supported.
  loadMoreData,

  /// In an error occurs.
  onErrorRefresh,
}
