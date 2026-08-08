import 'package:paginated_items_builder/paginated_items_builder.dart';

/// Lets a controller merge a fetched page without spelling out the
/// null-or-reset branch every time.
extension PaginatedItemsResponseMerge<T> on PaginatedItemsResponse<T>? {
  /// Merges [newResponse] into this response and returns the result.
  ///
  /// Adopts [newResponse] wholesale when there is nothing to merge into (this
  /// is null) or when [reset] is true, which is what a pull-to-refresh wants.
  /// Otherwise the incoming page is merged in and this response is returned.
  ///
  /// Replaces the usual controller boilerplate:
  ///
  /// ```dart
  /// if (reset || _response == null) {
  ///   _response = res;
  /// } else {
  ///   _response!.update(res);
  /// }
  /// ```
  ///
  /// with:
  ///
  /// ```dart
  /// _response = _response.merge(res, reset: reset);
  /// ```
  ///
  /// Deliberately not named `update`: an extension method on a nullable type
  /// is shadowed by the instance method of the same name whenever the
  /// receiver is known to be non-null, so `update` would silently mean two
  /// different things depending on the static type at the call site.
  PaginatedItemsResponse<T> merge(
    PaginatedItemsResponse<T> newResponse, {
    bool reset = false,
  }) {
    final current = this;
    if (reset || current == null) return newResponse;

    current.update(newResponse);
    return current;
  }
}
