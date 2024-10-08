import 'dart:developer' as dev;

extension PaginationModelExtension<T> on PaginatedItemsResponse<T>? {
  // do not call this like response?.update, call it like response.update...
  PaginatedItemsResponse<T> update(
    PaginatedItemsResponse<T> newResponse, {
    bool reset = false,
  }) {
    return reset || this == null ? newResponse : this!._update(newResponse);
  }
}

class PaginatedItemsResponse<T> {
  dynamic paginationKey;
  List<T> data;
  int itemsPerPage;
  final String Function(T) idGetter;
  final dynamic Function(T) _paginationKeyGetter;

  List<T> get items => data;

  dynamic getPaginationKeyForItem(T item) => _paginationKeyGetter(item);

  dynamic getPaginationKeyForItemAtIndex(int index) =>
      getPaginationKeyForItem(data[index]);

  static bool _calculateHasMore({
    required int dataLength,
    required int itemsPerPage,
  }) {
    return dataLength >= itemsPerPage;
  }

  late bool _hasMore;

  PaginatedItemsResponse.empty({
    required this.idGetter,
  })  : paginationKey = null,
        _hasMore = false,
        itemsPerPage = 0,
        data = const [],
        _paginationKeyGetter = ((_) => null);

  PaginatedItemsResponse.fromListWithNoPaginationSupport({
    required this.data,
    required this.idGetter,
  })  : paginationKey = null,
        _hasMore = false,
        itemsPerPage = 0,
        _paginationKeyGetter = ((_) => null);

  PaginatedItemsResponse({
    required this.data,
    required this.itemsPerPage,
    required dynamic Function(T) paginationKeyGetter,
    required this.idGetter,
    dynamic defaultPaginationKey,
  })  : _hasMore = _calculateHasMore(
          dataLength: data.length,
          itemsPerPage: itemsPerPage,
        ),
        _paginationKeyGetter = paginationKeyGetter,
        paginationKey = defaultPaginationKey ??
            _getPaginationKey(
              data,
              paginationKeyGetter: paginationKeyGetter,
            );

  bool get hasMore => _hasMore;

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;

  int get length => data.length;

  PaginatedItemsResponse<N> updateListWithNewType<N>(
    N Function(T) mapper, {
    required dynamic Function(N) paginationKeyGetter,
    required String Function(N) idGetter,
  }) {
    return PaginatedItemsResponse<N>(
      data: data.map(mapper).toList().cast<N>(),
      itemsPerPage: itemsPerPage,
      idGetter: idGetter,
      paginationKeyGetter: paginationKeyGetter,
      defaultPaginationKey: paginationKey,
    ).._hasMore = _hasMore;
  }

  void addAll(
    Iterable<T> newData, {
    bool shouldUpdatePaginationKey = true,
  }) {
    data = <T>[...data];

    final existingIds = data.map(idGetter).toSet();

    data.addAll(
      newData.where((e) => !existingIds.contains(idGetter(e))),
    );

    if (shouldUpdatePaginationKey) updatePaginationKey();
  }

  PaginatedItemsResponse<T> _update(PaginatedItemsResponse<T> newResponse) {
    itemsPerPage = newResponse.itemsPerPage;

    _hasMore = _calculateHasMore(
      dataLength: newResponse.length,
      itemsPerPage: itemsPerPage,
    );

    if (newResponse.isNotEmpty) {
      addAll(newResponse.data, shouldUpdatePaginationKey: false);
      paginationKey = newResponse.paginationKey;
    }

    return this;
  }

  void insert(
    T item, {
    int insertionIdx = 0,
    bool removeLastIfExceedsItemsPerPage = true,
    bool shouldUpdatePaginationKey = true,
  }) {
    data = <T>[...data];
    data.insert(insertionIdx, item);

    if (removeLastIfExceedsItemsPerPage && data.length > itemsPerPage) {
      data.removeLast();
    }

    if (shouldUpdatePaginationKey) updatePaginationKey();
  }

  void updatePaginationKey() {
    paginationKey = _getPaginationKey(
      data,
      paginationKeyGetter: _paginationKeyGetter,
    );
  }

  static dynamic _getPaginationKey<T>(
    List<T> data, {
    required dynamic Function(T) paginationKeyGetter,
  }) {
    return data.isEmpty ? null : paginationKeyGetter(data.last);
  }

  PaginatedItemsResponse<T> map(
    T Function(T) mapper, {
    bool inPlace = false,
    bool shouldUpdatePaginationKey = true,
  }) {
    if (inPlace) {
      data = data.map(mapper).toList().cast<T>();
      if (shouldUpdatePaginationKey) updatePaginationKey();
      return this;
    } else {
      return PaginatedItemsResponse<T>(
        data: data.map(mapper).toList().cast<T>(),
        itemsPerPage: itemsPerPage,
        idGetter: idGetter,
        defaultPaginationKey: paginationKey,
        paginationKeyGetter: _paginationKeyGetter,
      ).._hasMore = _hasMore;
    }
  }

  PaginatedItemsResponse<T> filter(
    bool Function(T) predicate, {
    bool inPlace = false,
    bool shouldUpdatePaginationKey = true,
  }) {
    if (inPlace) {
      data = data.where(predicate).toList().cast<T>();
      if (shouldUpdatePaginationKey) updatePaginationKey();
      return this;
    } else {
      return PaginatedItemsResponse<T>(
        data: data.where(predicate).toList().cast<T>(),
        itemsPerPage: itemsPerPage,
        idGetter: idGetter,
        defaultPaginationKey: paginationKey,
        paginationKeyGetter: _paginationKeyGetter,
      ).._hasMore = _hasMore;
    }
  }

  bool updateItemWithId(
    String id, {
    required T Function(T?) updater,
    bool addIfDoesNotExist = false,
    bool shouldUpdatePaginationKey = true,
  }) {
    bool didUpdate = false;

    final index = data.indexWhere((e) => idGetter(e) == id);
    if (addIfDoesNotExist && index == -1) {
      data.add(updater(null));
      didUpdate = true;
    } else {
      data[index] = updater(data[index]);
      didUpdate = true;
    }

    if (didUpdate && shouldUpdatePaginationKey) updatePaginationKey();

    return didUpdate;
  }

  T? findById(String id) {
    final idx = data.indexWhere((e) => id == idGetter(e));
    if (idx != -1) return data[idx];

    return null;
  }

  void log() => dev.log('\n${toString()}', name: 'PaginatedItemsResponse<$T>');

  @override
  String toString() {
    final itemsArrString = data
        .map((item) => item.toString())
        .map((itemName) => '\t\t$itemName,')
        .join('\n');

    return """
PaginatedItemsResponse<$T>({
  items: [\n$itemsArrString\n\t],
  paginationKey: $paginationKey,
});""";
  }

  /// Clear the contents.
  void clear() {
    data = [];
    itemsPerPage = 0;
    _hasMore = false;
    paginationKey = null;
  }

  void operator []=(int index, T value) => data[index] = value;

  T operator [](int index) => data[index];
}
