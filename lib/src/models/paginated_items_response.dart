import 'dart:developer' as dev;

/// The response object that carries the list of items
/// and handles pagination internally if [paginationKey] is specified.
class PaginatedItemsResponse<T> {
  /// Creates a response holding one page of results.
  ///
  /// Pass `paginationKey: null` if the API does not support pagination — that
  /// states the intent rather than leaving it to be inferred from an absence.
  PaginatedItemsResponse({
    required this.idGetter,
    required Iterable<T>? listItems,
    required this.paginationKey,
  }) : items = <T>[] {
    if (listItems != null) updateItems(listItems);
  }

  /// Creates an empty response, for holding a non-nullable response object
  /// before the first page has been fetched. Merge pages into it with
  /// [update].
  PaginatedItemsResponse.empty({
    required this.idGetter,
  }) : items = <T>[],
       paginationKey = null;

  /// List of items of type [T]
  List<T>? items;

  /// The pagination key. Can be null.
  dynamic paginationKey;

  /// Returns the unique id of an item of type [T].
  ///
  /// Used to replace, rather than duplicate, an item that arrives again in a
  /// later page, and to locate items in [updateItem] and [findByUid].
  final String Function(T) idGetter;

  /// If pagination supported, check if there is more data that can be loaded.
  bool get hasMoreData => paginationKey != null;

  /// True if [items] is not null.
  bool get hasData => items != null;

  /// Find an object by [id]. Returns null if there is no such item.
  T? findByUid(String id) {
    final currentItems = items;
    if (currentItems == null) return null;

    for (final item in currentItems) {
      if (idGetter(item) == id) return item;
    }

    return null;
  }

  T? operator [](int index) => items?[index];

  void operator []=(int index, T value) => items?[index] = value;

  /// update a specific item with uid, or add if does not exists according to
  /// [addIfDoesNotExist].
  ///
  /// If [item] is null, then the item is removed.
  void updateItem(String itemUid, T? item, {bool addIfDoesNotExist = false}) {
    final currentItems = items;
    if (currentItems == null) {
      if (item != null && addIfDoesNotExist) items = [item];
      return;
    }

    final idx = currentItems.indexWhere((e) => itemUid == idGetter(e));
    if (idx != -1) {
      if (item == null) {
        currentItems.removeAt(idx);
      } else {
        currentItems[idx] = item;
      }
    } else {
      if (item != null && addIfDoesNotExist) currentItems.add(item);
    }
  }

  /// Updates the response, merging in the items of [res]
  /// and adopting its pagination key.
  void update(PaginatedItemsResponse<T> res) {
    updateItems(res.items ?? const []);
    paginationKey = res.paginationKey;
  }

  /// Update many items at once, replacing any whose id already exists and
  /// appending the rest according to [addIfDoesNotExist].
  ///
  /// This is the bulk form of [updateItem]. It indexes the existing ids once
  /// instead of rescanning the list for every item, so prefer it over calling
  /// [updateItem] in a loop.
  void updateItems(Iterable<T> newItems, {bool addIfDoesNotExist = true}) {
    final currentItems = items ??= [];

    final indexById = <String, int>{
      for (int i = 0; i < currentItems.length; i++) idGetter(currentItems[i]): i,
    };

    for (final item in newItems) {
      final id = idGetter(item);
      final idx = indexById[id];

      if (idx == null) {
        if (!addIfDoesNotExist) continue;

        indexById[id] = currentItems.length;
        currentItems.add(item);
      } else {
        currentItems[idx] = item;
      }
    }
  }

  /// Logs the response.
  void log() => dev.log('\n${toString()}', name: 'PaginatedItemsResponse<$T>');

  @override
  String toString() {
    final itemsArrString = items?.map((item) => item.toString()).map((itemName) => '\t\t$itemName,').join('\n');

    return """
PaginatedItemsResponse<$T>({
  items: ${items == null ? 'null' : '[\n$itemsArrString\n\t],'}
  paginationKey: $paginationKey,
});""";
  }

  /// Clear the contents.
  void clear() {
    items = null;
    paginationKey = null;
  }
}
