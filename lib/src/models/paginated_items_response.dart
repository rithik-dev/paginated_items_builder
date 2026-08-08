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
    this.itemsPerPage,
  }) : assert(
         itemsPerPage == null || itemsPerPage > 0,
         'itemsPerPage must be greater than zero. Zero would make every page '
         'look full, so the list would never stop asking for more.',
       ),
       items = <T>[] {
    // Materialised once: `listItems` is often a lazy `map()`, and both the
    // merge and the page-length below would otherwise walk it separately.
    final page = listItems?.toList();
    if (page != null) {
      updateItems(page);
      _lastPageLength = page.length;
    }
  }

  /// Creates an empty response, for holding a response object before the first
  /// page has been fetched. Merge pages into it with [update].
  PaginatedItemsResponse.empty({required this.idGetter, this.itemsPerPage})
    : assert(
        itemsPerPage == null || itemsPerPage > 0,
        'itemsPerPage must be greater than zero.',
      ),
      items = <T>[],
      paginationKey = null;

  /// The items held, in the order they arrived.
  ///
  /// Never null: a response that exists has a list, even if it is empty. Use a
  /// nullable `PaginatedItemsResponse` to represent "nothing fetched yet" —
  /// that is what [PaginatedItemsBuilder.response] does, and it is why the
  /// builder can tell a first load apart from a genuinely empty result.
  ///
  /// The list itself is fixed; its contents are not. Mutate it through
  /// [updateItem], [updateItems] and [clear] rather than reassigning.
  final List<T> items;

  /// The pagination key. Can be null.
  dynamic paginationKey;

  /// Returns the unique id of an item of type [T].
  ///
  /// Used to replace, rather than duplicate, an item that arrives again in a
  /// later page, and to locate items in [updateItem] and [findByUid].
  final String Function(T) idGetter;

  /// How many items make up a full page, for APIs that page by size rather
  /// than by cursor.
  ///
  /// When set, [hasMoreData] stops depending on [paginationKey] and instead
  /// reports whether the last page came back full: a short page means the end
  /// of the list. Leave it null for APIs that signal the end with a null
  /// pagination key.
  final int? itemsPerPage;

  /// How many items the most recently merged page contained, before
  /// de-duplication. Null until the first page arrives.
  int? _lastPageLength;

  /// Whether there is more data that can be loaded.
  ///
  /// Derived from [itemsPerPage] when it is set — a page shorter than a full
  /// one means there is nothing left — and from [paginationKey] otherwise.
  bool get hasMoreData {
    final perPage = itemsPerPage;
    if (perPage == null) return paginationKey != null;

    final lastPageLength = _lastPageLength;
    // Nothing fetched yet, so assume a first page is waiting.
    return lastPageLength == null || lastPageLength >= perPage;
  }

  /// The number of items held.
  int get length => items.length;

  /// True when there are no items.
  bool get isEmpty => items.isEmpty;

  /// True when there is at least one item.
  bool get isNotEmpty => items.isNotEmpty;

  /// Find an object by [id]. Returns null if there is no such item.
  T? findByUid(String id) {
    for (final item in items) {
      if (idGetter(item) == id) return item;
    }

    return null;
  }

  T operator [](int index) => items[index];

  void operator []=(int index, T value) => items[index] = value;

  /// update a specific item with uid, or add if does not exists according to
  /// [addIfDoesNotExist].
  ///
  /// If [item] is null, then the item is removed.
  void updateItem(String itemUid, T? item, {bool addIfDoesNotExist = false}) {
    final idx = items.indexWhere((e) => itemUid == idGetter(e));
    if (idx != -1) {
      if (item == null) {
        items.removeAt(idx);
      } else {
        items[idx] = item;
      }
    } else {
      if (item != null && addIfDoesNotExist) items.add(item);
    }
  }

  /// Update many items at once, replacing any whose id already exists and
  /// appending the rest according to [addIfDoesNotExist].
  ///
  /// This is the bulk form of [updateItem]. It indexes the existing ids once
  /// instead of rescanning the list for every item, so prefer it over calling
  /// [updateItem] in a loop.
  void updateItems(Iterable<T> newItems, {bool addIfDoesNotExist = true}) {
    final indexById = <String, int>{
      for (int i = 0; i < items.length; i++) idGetter(items[i]): i,
    };

    for (final item in newItems) {
      final id = idGetter(item);
      final idx = indexById[id];

      if (idx == null) {
        if (!addIfDoesNotExist) continue;

        indexById[id] = items.length;
        items.add(item);
      } else {
        items[idx] = item;
      }
    }
  }

  /// Updates the response, merging in the items of [res]
  /// and adopting its pagination key.
  void update(PaginatedItemsResponse<T> res) {
    updateItems(res.items);
    paginationKey = res.paginationKey;
    // The raw page length, before de-duplication — that is what tells us
    // whether the API had a full page left to give.
    _lastPageLength = res.items.length;
  }

  /// Logs the response.
  void log() => dev.log('\n${toString()}', name: 'PaginatedItemsResponse<$T>');

  @override
  String toString() {
    final itemsArrString = items.map((item) => item.toString()).map((itemName) => '\t\t$itemName,').join('\n');

    return """
PaginatedItemsResponse<$T>({
  items: [\n$itemsArrString\n\t],
  paginationKey: $paginationKey,
});""";
  }

  /// Clear the contents.
  void clear() {
    items.clear();
    paginationKey = null;
    _lastPageLength = null;
  }
}
