# [PaginatedItemsBuilder](https://pub.dev/packages/paginated_items_builder) For Flutter
[![pub package](https://img.shields.io/pub/v/paginated_items_builder.svg)](https://pub.dev/packages/paginated_items_builder)
[![likes](https://badges.bar/paginated_items_builder/likes)](https://pub.dev/packages/paginated_items_builder/score)
[![popularity](https://badges.bar/paginated_items_builder/popularity)](https://pub.dev/packages/paginated_items_builder/popularity)
[![pub points](https://badges.bar/paginated_items_builder/pub%20points)](https://pub.dev/packages/paginated_items_builder/pub%20points)

*Easier to display items in a list/grid view from your controllers directly or handling state internally with support for pagination. 
Saves the results in state to avoid unnecessary api calls everytime screen is pushed.*

### Screenshots
<img src="https://user-images.githubusercontent.com/56810766/148798681-2077ac11-cdf4-46a8-8718-90e32661f1ab.jpeg" height=600/>&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/56810766/148798642-a4a87582-928d-42ad-b7e0-f752842974bb.jpeg" height=600/>&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/56810766/148798666-6224bae3-e08c-4efb-b967-9cdc1bc49d6e.jpeg" height=600/>

## Usage

To use this plugin, add [`paginated_items_builder`](https://pub.dev/packages/paginated_items_builder) as a dependency in your pubspec.yaml file.

```yaml
  dependencies:
    flutter:
      sdk: flutter
    paginated_items_builder:
```

First and foremost, import the widget.
```dart
import 'package:paginated_items_builder/paginated_items_builder.dart';
```

You can now add an [`PaginatedItemsBuilder`](https://github.com/rithik-dev/paginated_items_builder/blob/master/lib/src/paginated_items_builder.dart) widget to your widget tree.

Here, let's consider a list of products.

First, in the controller, let's define a variable for handling the products response. 
(typically inside the specific controller) and a public getter to access it in the UI.

```dart
PaginatedItemsResponse<Product>? _productsResponse;

PaginatedItemsResponse<Product>? get productsResponse => _productsResponse;
```

Now, define a function to handle the state of the list, function that handles calling the api and 
getting the results.

```dart
Future<void> updateProducts({
  bool reset = false,
  bool showLoaderOnReset = false,
}) async {
  if (reset && showLoaderOnReset) {
    _productsResponse = null;
    notifyListeners();
  }

  final res = await apiFunction(
    // startKey is optional and only required when you have pagination support in api
    startKey: reset ? null : _productsResponse?.paginationKey,
  );
  if (reset || _productsResponse == null) {
    _productsResponse = res;
  } else {
    _productsResponse!.update(res);
  }
  notifyListeners();
}
```

The `apiFunction` can be defined as:

```dart
Future<PaginatedItemsResponse<Product>?> apiFunction({
  // can be string or int (page number) or any other type.
  dynamic startKey,
}) async {
  // startKey necessary if pagination support
  final res = await _api.getProducts(startKey: startKey);

  return PaginatedItemsResponse<Product>(

    // list of items
    listItems: res.data?.products,

    // only required to pass if pagination supported, else null. (can be of any type)
    paginationKey: res.data?.paginationKey,

    // unique id, should only be passed in the repository function.
    // required for functions like `updateItem`, `findByUid`
    // and avoiding duplication of items in list (compares uid)
    idGetter: (product) => product.id,

  );
}
```

Now, can use this widget like shown in the widget tree:
(No need to handle a refresh indicator separately. It is already present.)

When the reset from fetchPageData fn is true, your code should handle the logic to update
and replace the existing contents. Basically update all items. Much like a pull-down refresh.

The fetchPageData provides 2 callback values, first one being the `reset` flag(boolean).
If that is true, that means an action was triggered which requires to
force reload the items of the list.

The 2nd value is the `ItemsFetchScope`, which defines the action calling the
fetch data function.

The `reset` flag will be true only when the `itemsFetchScope` is either
`ItemsFetchScope.noItemsRefresh` i.e. no items were found, and user
clicked the refresh icon OR `ItemsFetchScope.pullDownToRefresh` i.e.
the user wants to refresh the list contents with pull-down action.

```dart
PaginatedItemsBuilder<Product>(
    fetchPageData: (reset, itemsFetchScope) => controller.updatePosts(
        reset: reset,
        showLoaderOnReset: itemsFetchScope == ItemsFetchScope.noItemsRefresh,
    ),
    response: controller.productsResponse,
    itemBuilder: (context, index, item) => Text('Item$index : $item'),
),
```

If the state is handled using PaginationItemsStateHandler, then fetchPageData is handled internally
and is provided in the `builder` callback.

Use it as follows:
```dart
/// function which calls the API and returns `PaginatedItemsResponse`.
Future<PaginatedItemsResponse<Post>?> updatePosts(dynamic paginationKey) async {
  return await PostsRepository.getPosts(startKey: paginationKey);
}

PaginationItemsStateHandler<Post>(
    fetchPageData: updatePosts,
    builder: (response, fetchPageData) {
        return PaginatedItemsBuilder<Post>(
            response: response,
            fetchPageData: fetchPageData,
            itemBuilder: (context, idx, post) => PostCard(post),
            loaderItemsCount: 10,
        );
    },
),
```

## Customization

To see the shimmer loader in play, you need to provide a mock items getter.. What basically happens
is that this 'MockItem' is basically an object of the class `T` which is passed in
the `PaginatedItemsBuilder` class.

Generate a class like shown:
```dart
class MockItems {
  static dynamic getByType<T>([String? key]) {
    final typeKey = key ?? T.toString();
    switch (typeKey) {
      case 'Category':
        return _category as T;
    }
  }

  static final _category = Category.fromJson({
    'id': 'id',
    'name': '■■■■■■',
  });
}
```

and then pass the reference to the `getByType` function to the `PaginatedItemsBuilderConfig`.
```dart
PaginatedItemsBuilder.config = PaginatedItemsBuilderConfig(
    mockItemGetter: MockItems.getByType,
);
```

In the `PaginatedItemsBuilderConfig`, you can also customize the shimmer loader colors etc.
```dart
PaginatedItemsBuilder.config = PaginatedItemsBuilderConfig(
    mockItemGetter: MockItems.getByType,
    shimmerConfig: ShimmerConfig(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[200],
    ),
);
```

The config can be initialized in the MaterialApp's builder property. It is also possible to
pass different colors for different themes as shown:
```dart
MaterialApp(
    title: 'PaginatedItemsBuilder Demo',
    builder: (context, child) {
        late final Color shimmerBaseColor;
        late final Color shimmerHighlightColor;
        
        switch (Theme.of(context).brightness) {
            case Brightness.light:
                shimmerBaseColor = Colors.grey[300]!;
                shimmerHighlightColor = Colors.grey[100]!;
                break;
            case Brightness.dark:
                shimmerBaseColor = const Color(0xFF031956);
                shimmerHighlightColor = const Color(0x80031956);
                break;
        }
        
        PaginatedItemsBuilder.config = PaginatedItemsBuilderConfig(
            mockItemGetter: MockItems.getByType,
            shimmerConfig: ShimmerConfig(
                baseColor: shimmerBaseColor,
                highlightColor: shimmerHighlightColor,
                duration: const Duration(seconds: 1),
            ),
        );
        
        return child!;
    },
);
```

Want to show items as a grid? Change the cross axis count? Pass in a custom scroll controller?
Well, there are a lot of parameters that can be customized in [`PaginatedItemsBuilder`](https://github.com/rithik-dev/paginated_items_builder/blob/master/lib/src/paginated_items_builder.dart)

See the [`example`](https://github.com/rithik-dev/paginated_items_builder/blob/master/example) directory for a complete sample app.

### Created & Maintained By `Rithik Bhandari`

* GitHub: [@rithik-dev](https://github.com/rithik-dev)
* LinkedIn: [@rithik-bhandari](https://www.linkedin.com/in/rithik-bhandari/)

