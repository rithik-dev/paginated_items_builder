import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

PaginatedItemsResponse<String> _response({
  List<String> items = const [],
  dynamic paginationKey,
}) {
  return PaginatedItemsResponse<String>(
    idGetter: (item) => item,
    listItems: items,
    paginationKey: paginationKey,
  );
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  setUp(() => PaginatedItemsBuilder.config = null);
  tearDown(() => PaginatedItemsBuilder.config = null);

  testWidgets('renders an item for every entry in the response', (tester) async {
    final response = _response(items: const ['alpha', 'beta']);

    await tester.pumpWidget(
      _wrap(
        PaginatedItemsBuilder<String>(
          response: response,
          logErrors: false,
          fetchPageData: (reset) async => response,
          itemBuilder: (context, index, item) => Text(item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('alpha'), findsOneWidget);
    expect(find.text('beta'), findsOneWidget);
  });

  testWidgets('a response built with listItems: null shows the empty state', (tester) async {
    // `items` must end up [] rather than null here. The builder reads null as
    // "nothing fetched yet" and renders loaderItemsCount shimmer tiles with no
    // refresh affordance, so a fetch that legitimately returned no rows would
    // look like it was still loading, forever.
    final response = PaginatedItemsResponse<String>(
      idGetter: (item) => item,
      listItems: null,
      paginationKey: null,
    );

    expect(response.items, isNotNull);

    await tester.pumpWidget(
      _wrap(
        PaginatedItemsBuilder<String>(
          response: response,
          logErrors: false,
          noItemsWidgetBuilder: (typeKey, refreshOnTap) => const Text('nothing here'),
          fetchPageData: (reset) async => response,
          itemBuilder: (context, index, item) => Text(item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('nothing here'), findsOneWidget);
  });

  testWidgets('shows the no-items widget from the config when empty', (tester) async {
    // These three config builders were declared `late final` but never
    // assigned, so reading them threw a LateInitializationError and they could
    // never actually be used.
    PaginatedItemsBuilder.config = PaginatedItemsBuilderConfig(
      logErrors: false,
      noItemsWidgetBuilder: (typeKey, refreshOnTap) => Text('empty:$typeKey', textDirection: TextDirection.ltr),
    );

    final response = _response();

    await tester.pumpWidget(
      _wrap(
        PaginatedItemsBuilder<String>(
          response: response,
          fetchPageData: (reset) async => response,
          itemBuilder: (context, index, item) => Text(item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('empty:String'), findsOneWidget);
  });

  testWidgets('shows the error widget from the config when the fetch throws', (tester) async {
    PaginatedItemsBuilder.config = PaginatedItemsBuilderConfig(
      logErrors: false,
      errorWidgetBuilder: (error, refreshOnTap) => Text('failed: $error'),
    );

    await tester.pumpWidget(
      _wrap(
        PaginatedItemsBuilder<String>(
          response: _response(),
          fetchPageData: (reset) async => throw 'boom',
          itemBuilder: (context, index, item) => Text(item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('failed: boom'), findsOneWidget);
  });

  testWidgets('uses the refresh icon builder from the config', (tester) async {
    PaginatedItemsBuilder.config = PaginatedItemsBuilderConfig(
      logErrors: false,
      refreshIconBuilder: (refreshOnTap) => TextButton(onPressed: refreshOnTap, child: const Text('retry')),
    );

    final response = _response();

    await tester.pumpWidget(
      _wrap(
        PaginatedItemsBuilder<String>(
          response: response,
          fetchPageData: (reset) async => response,
          itemBuilder: (context, index, item) => Text(item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('retry'), findsOneWidget);
  });

  testWidgets('widget-level builders win over the config', (tester) async {
    PaginatedItemsBuilder.config = PaginatedItemsBuilderConfig(
      logErrors: false,
      noItemsWidgetBuilder: (typeKey, refreshOnTap) => const Text('from config'),
    );

    final response = _response();

    await tester.pumpWidget(
      _wrap(
        PaginatedItemsBuilder<String>(
          response: response,
          fetchPageData: (reset) async => response,
          noItemsWidgetBuilder: (typeKey, refreshOnTap) => const Text('from widget'),
          itemBuilder: (context, index, item) => Text(item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('from widget'), findsOneWidget);
    expect(find.text('from config'), findsNothing);
  });

  testWidgets('paginates, and keeps paginating after a pull-to-refresh', (tester) async {
    // The bottom loader remembers the index it last fetched at. A reset used
    // to leave that memory in place, so a refresh landing on the same length
    // made the loader believe it had already fetched, and pagination stalled.
    final response = _response();
    var page = 0;
    var loadMoreFetches = 0;

    await tester.pumpWidget(
      _wrap(
        PaginatedItemsBuilder<String>(
          response: response,
          logErrors: false,
          loaderItemsCount: 1,
          fetchPageData: (reset) async {
            if (reset) {
              page = 0;
              response.clear();
            }
            page++;
            if (page == 1) {
              response.update(
                _response(items: const ['a', 'b'], paginationKey: 'p1'),
              );
            } else {
              loadMoreFetches++;
              // No pagination key on the last page, so pagination stops here
              // and the widget tree can settle.
              response.update(_response(items: const ['c', 'd']));
            }
            return response;
          },
          itemBuilder: (context, index, item) => SizedBox(height: 200, child: Text(item)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Page 1 plus the automatic second page fetched by the bottom loader.
    expect(loadMoreFetches, 1);
    expect(response.items, hasLength(4));

    // Pull down to refresh, which resets the list back to page 1.
    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    // The bottom loader must fetch page 2 again rather than assuming it
    // already did so at this index.
    expect(loadMoreFetches, 2);
    expect(response.items, hasLength(4));
  });

  testWidgets('PaginationItemsStateHandler feeds the builder', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PaginationItemsStateHandler<String>(
          fetchPageData: (paginationKey) async => _response(items: const ['one', 'two']),
          builder: (response, fetchPageData) => PaginatedItemsBuilder<String>(
            response: response,
            logErrors: false,
            fetchPageData: fetchPageData,
            itemBuilder: (context, index, item) => Text(item),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('one'), findsOneWidget);
    expect(find.text('two'), findsOneWidget);
  });

  testWidgets('disposing mid-fetch does not throw', (tester) async {
    // The old code called setState after dispose and swallowed the resulting
    // exception with a bare catch.
    final response = _response(items: const ['x']);

    await tester.pumpWidget(
      _wrap(
        PaginatedItemsBuilder<String>(
          response: response,
          logErrors: false,
          fetchPageData: (reset) async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return response;
          },
          itemBuilder: (context, index, item) => Text(item),
        ),
      ),
    );

    // Tear the widget down while the first fetch is still in flight.
    await tester.pumpWidget(_wrap(const SizedBox.shrink()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
