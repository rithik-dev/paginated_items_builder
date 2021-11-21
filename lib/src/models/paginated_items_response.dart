class PaginatedItemsResponse<T> {
  List<T>? items;
  dynamic paginationKey;
  String Function(T)? uidGetterFn;

  bool get hasMoreData {
    if (paginationKey == null) {
      return false;
    } else {
      return paginationKey!.length != 2;
    }
  }

  T? findByUid(String uid) {
    final idx = items?.indexWhere((e) => uid == uidGetterFn!(e));
    if (idx != null && idx != -1) return items?[idx];
  }

  PaginatedItemsResponse({
    String Function(T)? idGetter,
    Iterable<T>? listItems,
    dynamic lastKey,
  }) {
    uidGetterFn ??= idGetter;
    _update(listItems, lastKey);
  }

  void update(PaginatedItemsResponse<T>? res) {
    if (res != null) _update(res.items, res.paginationKey);
  }

  void updateItem(
    String itemUid,
    T? item, {
    bool addIfDoesNotExist = false,
  }) {
    final idx = items!.indexWhere((e) => itemUid == uidGetterFn!(e));
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

  void _update(Iterable<T>? listItems, dynamic lastKey) {
    items ??= [];
    if (listItems != null) {
      for (final item in listItems) {
        updateItem(uidGetterFn!(item), item, addIfDoesNotExist: true);
      }
    }
    paginationKey = lastKey?.toString();
  }

  void clear() {
    items = null;
    paginationKey = null;
  }
}
