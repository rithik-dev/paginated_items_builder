/// The response object that carries the list of items and handles pagination
/// internally. The [paginationKey] is optional and can be of any type. If not passed,
/// it is assumed that the API does not support pagination.
///
///
/// The [idGetter] should be passed when receiving the response from the API, it
/// is required for functions like `updateItem`, `findByUid`
/// and avoiding duplication of items in list (compares id).
class PaginatedItemsResponse<T> {
  /// List of items of type [T]
  List<T>? items;

  /// The pagination key. Can be null.
  dynamic paginationKey;

  /// ID getter for the object of type [T].
  String Function(T)? _idGetterFn;

  /// If pagination supported, check if there is more data that can be loaded.
  bool get hasMoreData => paginationKey != null;

  /// Find an object by [id].
  T? findByUid(String id) {
    final idx = items?.indexWhere((e) => id == _idGetterFn!(e));
    if (idx != null && idx != -1) return items?[idx];
  }

  /// constructor
  PaginatedItemsResponse({
    String Function(T)? idGetter,
    Iterable<T>? listItems,
    dynamic paginationKey,
  }) {
    _idGetterFn ??= idGetter;
    _update(listItems, paginationKey);
  }

  void update(PaginatedItemsResponse<T>? res) {
    if (res != null) _update(res.items, res.paginationKey);
  }

  /// update a specific item with uid, or add if does not exists according to
  /// [addIfDoesNotExist].
  void updateItem(
    String itemUid,
    T? item, {
    bool addIfDoesNotExist = false,
  }) {
    final idx = items!.indexWhere((e) => itemUid == _idGetterFn!(e));
    if (idx != -1) {
      if (item == null) {
        items!.removeAt(idx);
      } else {
        items![idx] = item;
      }
    } else {
      if (item != null && addIfDoesNotExist) items!.add(item);
    }
  }

  /// Append items to the list, after a successful fetch from the API.
  void _update(Iterable<T>? listItems, dynamic key) {
    items ??= [];
    if (listItems != null) {
      for (final item in listItems) {
        updateItem(_idGetterFn!(item), item, addIfDoesNotExist: true);
      }
    }
    paginationKey = key;
  }

  /// Clear the contents.
  void clear() {
    items = null;
    paginationKey = null;
  }
}
