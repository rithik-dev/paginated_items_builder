import 'package:flutter_test/flutter_test.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

class _Item {
  const _Item(this.id, this.name);

  final String id;
  final String name;
}

String _idOf(_Item item) => item.id;

void main() {
  group('PaginatedItemsResponse construction', () {
    test('keeps the items it was given', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a'), _Item('2', 'b')],
        paginationKey: 'next',
      );

      expect(res.items, hasLength(2));
      expect(res.hasMoreData, isTrue);
      expect(res.paginationKey, 'next');
    });

    test('hasMoreData is false when there is no pagination key', () {
      final res = PaginatedItemsResponse<_Item>.empty(idGetter: _idOf);
      expect(res.hasMoreData, isFalse);
      expect(res.items, isEmpty);
    });

    test('exposes the idGetter it was built with', () {
      final res = PaginatedItemsResponse<_Item>.empty(idGetter: _idOf);
      expect(res.idGetter(const _Item('7', 'g')), '7');
    });
  });

  group('PaginatedItemsResponse.update', () {
    test('appends a new page and adopts the new pagination key', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: 'p1',
      );

      res.update(
        PaginatedItemsResponse<_Item>(
          idGetter: _idOf,
          listItems: const [_Item('2', 'b')],
          paginationKey: 'p2',
        ),
      );

      expect(res.items.map(_idOf), ['1', '2']);
      expect(res.paginationKey, 'p2');
    });

    test('replaces items that share an id instead of duplicating them', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'old'), _Item('2', 'b')],
        paginationKey: null,
      );

      res.update(
        PaginatedItemsResponse<_Item>(
          idGetter: _idOf,
          listItems: const [_Item('1', 'new'), _Item('3', 'c')],
          paginationKey: null,
        ),
      );

      expect(res.items.map(_idOf), ['1', '2', '3']);
      expect(res.findByUid('1')!.name, 'new');
    });

    test('merges a first page into a response that was created empty', () {
      // The common controller shape: hold an empty response, then merge each
      // fetched page into it.
      final res = PaginatedItemsResponse<_Item>.empty(idGetter: _idOf);

      res.update(
        PaginatedItemsResponse<_Item>(
          idGetter: _idOf,
          listItems: const [_Item('1', 'a')],
          paginationKey: null,
        ),
      );
      expect(res.items, hasLength(1));

      // De-duplication applies from the very first merge.
      res.update(
        PaginatedItemsResponse<_Item>(
          idGetter: _idOf,
          listItems: const [_Item('1', 'a2')],
          paginationKey: null,
        ),
      );
      expect(res.items, hasLength(1));
      expect(res.findByUid('1')!.name, 'a2');
    });
  });

  group('PaginatedItemsResponse.updateItem', () {
    test('updates, adds and removes by id', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: null,
      );

      res.updateItem('1', const _Item('1', 'a2'));
      expect(res.findByUid('1')!.name, 'a2');

      res.updateItem('2', const _Item('2', 'b'), addIfDoesNotExist: true);
      expect(res.items, hasLength(2));

      res.updateItem('2', null);
      expect(res.items, hasLength(1));
    });

    test('does not add an unknown id unless asked to', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: null,
      );

      res.updateItem('9', const _Item('9', 'z'));
      expect(res.items, hasLength(1));
    });

    test('does not crash after clear()', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: null,
      );
      res.clear();
      expect(res.items, isEmpty);

      // items is empty here; this used to throw a null-check error when it
      // was null instead.
      expect(
        () => res.updateItem('1', const _Item('1', 'a'), addIfDoesNotExist: true),
        returnsNormally,
      );
      expect(res.items, hasLength(1));
    });
  });

  group('PaginatedItemsResponse.updateItems', () {
    test('replaces matching ids and appends the rest', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a'), _Item('2', 'b')],
        paginationKey: null,
      );

      res.updateItems(const [_Item('2', 'b2'), _Item('3', 'c')]);

      expect(res.items.map(_idOf), ['1', '2', '3']);
      expect(res.findByUid('2')!.name, 'b2');
    });

    test('honours addIfDoesNotExist: false', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: null,
      );

      res.updateItems(
        const [_Item('1', 'a2'), _Item('9', 'z')],
        addIfDoesNotExist: false,
      );

      expect(res.items.map(_idOf), ['1']);
      expect(res.findByUid('1')!.name, 'a2');
    });

    test('collapses duplicate ids within the incoming batch', () {
      final res = PaginatedItemsResponse<_Item>.empty(idGetter: _idOf);

      res.updateItems(const [_Item('1', 'first'), _Item('1', 'second')]);

      expect(res.items, hasLength(1));
      expect(res.findByUid('1')!.name, 'second');
    });
  });

  group('hasMoreData', () {
    test('follows the pagination key when itemsPerPage is not set', () {
      expect(
        PaginatedItemsResponse<_Item>(
          idGetter: _idOf,
          listItems: const [_Item('1', 'a')],
          paginationKey: 'next',
        ).hasMoreData,
        isTrue,
      );
      expect(
        PaginatedItemsResponse<_Item>(
          idGetter: _idOf,
          listItems: const [_Item('1', 'a')],
          paginationKey: null,
        ).hasMoreData,
        isFalse,
      );
    });

    test('a full page means more, a short page means the end', () {
      final full = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a'), _Item('2', 'b')],
        paginationKey: null,
        itemsPerPage: 2,
      );
      expect(full.hasMoreData, isTrue);

      final short = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: null,
        itemsPerPage: 2,
      );
      expect(short.hasMoreData, isFalse);
    });

    test('itemsPerPage wins over the pagination key', () {
      // A short page ends the list even though a key is still present.
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: 'still-here',
        itemsPerPage: 2,
      );
      expect(res.hasMoreData, isFalse);
    });

    test('is re-evaluated from the last merged page', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a'), _Item('2', 'b')],
        paginationKey: null,
        itemsPerPage: 2,
      );
      expect(res.hasMoreData, isTrue);

      res.update(
        PaginatedItemsResponse<_Item>(
          idGetter: _idOf,
          listItems: const [_Item('3', 'c')],
          paginationKey: null,
        ),
      );
      expect(res.hasMoreData, isFalse, reason: 'last page was short');
    });

    test('measures the raw page, not the de-duplicated result', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a'), _Item('2', 'b')],
        paginationKey: null,
        itemsPerPage: 2,
      );

      // A full page that happens to repeat known ids still means "more".
      res.update(
        PaginatedItemsResponse<_Item>(
          idGetter: _idOf,
          listItems: const [_Item('1', 'a2'), _Item('2', 'b2')],
          paginationKey: null,
        ),
      );
      expect(res.items, hasLength(2));
      expect(res.hasMoreData, isTrue);
    });

    test('an empty response assumes a first page is waiting', () {
      final res = PaginatedItemsResponse<_Item>.empty(
        idGetter: _idOf,
        itemsPerPage: 20,
      );
      expect(res.hasMoreData, isTrue);
    });

    test('rejects a non-positive itemsPerPage', () {
      expect(
        () => PaginatedItemsResponse<_Item>(
          idGetter: _idOf,
          listItems: const [],
          paginationKey: null,
          itemsPerPage: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('length / isEmpty / isNotEmpty', () {
    test('reflect the items held', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: null,
      );
      expect(res.length, 1);
      expect(res.isEmpty, isFalse);
      expect(res.isNotEmpty, isTrue);
    });

    test('remain zero and empty after clear', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: null,
      );
      expect(res.length, 1);

      res.clear();
      expect(res.length, 0);
      expect(res.isEmpty, isTrue);
    });
  });

  group('merge extension', () {
    test('adopts the new response when the receiver is null', () {
      PaginatedItemsResponse<_Item>? res;
      final incoming = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: 'p1',
      );

      res = res.merge(incoming);
      expect(identical(res, incoming), isTrue);
    });

    test('merges into the receiver when it exists', () {
      PaginatedItemsResponse<_Item>? res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: 'p1',
      );
      final first = res;

      res = res.merge(
        PaginatedItemsResponse<_Item>(
          idGetter: _idOf,
          listItems: const [_Item('2', 'b')],
          paginationKey: 'p2',
        ),
      );

      expect(identical(res, first), isTrue, reason: 'merged in place');
      expect(res.items.map(_idOf), ['1', '2']);
      expect(res.paginationKey, 'p2');
    });

    test('replaces wholesale on reset', () {
      PaginatedItemsResponse<_Item>? res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a'), _Item('2', 'b')],
        paginationKey: 'p1',
      );

      res = res.merge(
        PaginatedItemsResponse<_Item>(
          idGetter: _idOf,
          listItems: const [_Item('9', 'z')],
          paginationKey: null,
        ),
        reset: true,
      );

      expect(res.items.map(_idOf), ['9'], reason: 'old items discarded');
    });
  });

  group('PaginatedItemsResponse.findByUid', () {
    test('returns null when the id is absent', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: null,
      );
      expect(res.findByUid('nope'), isNull);
    });

    test('returns null on an empty response', () {
      final res = PaginatedItemsResponse<_Item>.empty(idGetter: _idOf)..clear();
      expect(res.findByUid('1'), isNull);
    });
  });

  group('PaginatedItemsResponse operators', () {
    test('index read and write', () {
      final res = PaginatedItemsResponse<_Item>(
        idGetter: _idOf,
        listItems: const [_Item('1', 'a')],
        paginationKey: null,
      );

      expect(res[0].name, 'a');
      res[0] = const _Item('1', 'changed');
      expect(res[0].name, 'changed');
    });
  });
}
