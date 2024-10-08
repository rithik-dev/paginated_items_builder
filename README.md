# [PaginatedItemsBuilder](https://pub.dev/packages/paginated_items_builder) For Flutter
[![pub package](https://img.shields.io/pub/v/paginated_items_builder.svg)](https://pub.dev/packages/paginated_items_builder)
[![likes](https://img.shields.io/pub/likes/paginated_items_builder)](https://pub.dev/packages/paginated_items_builder/score)
[![popularity](https://img.shields.io/pub/popularity/paginated_items_builder)](https://pub.dev/packages/paginated_items_builder/score)
[![pub points](https://img.shields.io/pub/points/paginated_items_builder)](https://pub.dev/packages/paginated_items_builder/score)
[![code size](https://img.shields.io/github/languages/code-size/rithik-dev/paginated_items_builder)](https://github.com/rithik-dev/paginated_items_builder)
[![license MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

Easier to display items in a list/grid view from your controllers directly or handling state internally with support for pagination.
Saves the results in state to avoid unnecessary api calls everytime screen is pushed.

---

# 🗂️ Table of Contents

- **[📷 Screenshots](#-screenshots)**
- **[✨ Features](#-features)**
- **[❓ Usage](#-usage)**
  - [Shimmer loader](#shimmer-loader)
  - [PaginatedItemsBuilder Config](#paginateditemsbuilder-config)
  - [Supporting multiple themes](#supporting-multiple-themes)
- **[🎯 Sample Usage](#-sample-usage)**
- **[👤 Collaborators](#-collaborators)**

---

# 📷 Screenshots

| Loading Shimmer Animation | Loaded List View |
|-----------------------------------|-------------------------------------|
| <img src="https://user-images.githubusercontent.com/56810766/148798681-2077ac11-cdf4-46a8-8718-90e32661f1ab.jpeg" height="500"> | <img src="https://user-images.githubusercontent.com/56810766/148798666-6224bae3-e08c-4efb-b967-9cdc1bc49d6e.jpeg" height="500"> |

---

# ✨ Features

- **Easy Pagination Handling:** Effortlessly display paginated data with built-in support for handling API pagination.
- **State Management:** Manage state internally within the widget or externally through controllers, ensuring optimized API calls by caching results.
- **List or Grid View:** Customize how your items are displayed by toggling between list or grid views.
- **Shimmer Loader:** Built-in shimmer loader for smoother UX during data loading, with customizable shimmer animation colors and duration.
- **Automatic Refresh:** Includes pull-down refresh and error refresh functionalities to reload data dynamically.
- **Seamless UI Updates:** On data refresh, update only the relevant items without unnecessary UI flickering or reloading.
- **Error Handling:** Built-in handling of errors during API calls, with the ability to refresh on error.

---

# ❓ Usage

1. Add [`paginated_items_builder`](https://pub.dev/packages/paginated_items_builder) as a dependency in your pubspec.yaml file.
```yaml
dependencies:
  flutter:
    sdk: flutter

  paginated_items_builder:
```

2. Add [`PaginatedItemsBuilder`](https://github.com/rithik-dev/paginated_items_builder/blob/master/lib/src/paginated_items_builder.dart) widget to your widget tree.
Here, let's consider a list of posts.

In the controller, let's define a variable for handling the posts response (typically inside the specific controller) and a public getter to access it in the UI.

```dart
PaginatedItemsResponse<Post>? _postsResponse;

PaginatedItemsResponse<Post>? get postsResponse => _postsResponse;
```

Define a function to handle the state of the list, function that handles calling the api, getting the results and return the response handler from it.
```dart
Future<PaginatedItemsResponse<Post>?> updatePosts({bool reset = false}) async {
  final res = await apiFunction(
    // startKey is optional and only required when you have pagination support in api
    startKey: reset ? null : _postsResponse?.paginationKey,
  );
  
  if (reset || _postsResponse == null) {
    // if res here is null, then an exception is thrown...
    _postsResponse = res;
  } else {
    _postsResponse?.update(res);
  }
  notifyListeners();
  return _postsResponse;
}
```

The `apiFunction` can be defined as:
```dart
Future<PaginatedItemsResponse<Post>> apiFunction({
  // can be string or int (page number) or any other type.
  dynamic startKey,
}) async {
    // startKey necessary if pagination support
    final res = await _api.getPosts(startKey: startKey);

    return PaginatedItemsResponse<Post>(

      // list of items
      listItems: res.data?.posts,

      // only required to pass if pagination supported, else null. (can be of any type)
      paginationKey: res.data?.paginationKey,

      // unique id, should only be passed in the repository function.
      // required for functions like `updateItem`, `findByUid`
      // and avoiding duplication of items in list (compares uid)
      idGetter: (post) => post.id,
    );
}
```

Now, can use this widget like shown in the widget tree:
(No need to handle a refresh indicator separately. It is already present.)

When the reset from fetchPageData fn is true, your code should handle the logic to update
and replace the existing contents. Basically update all items. Much like a pull-down refresh.

The fetchPageData provides the `reset` flag(boolean).
If that is true, that means an action was triggered which requires to
force reload the items of the list.

The `reset` flag will be true only when the `itemsFetchScope` is either
`ItemsFetchScope.noItemsRefresh` i.e. no items were found, and user
clicked the refresh icon OR `ItemsFetchScope.pullDownToRefresh` i.e.
the user wants to refresh the list contents with pull-down action OR 
`ItemsFetchScope.onErrorRefresh` if an error occurs.
```dart
PaginatedItemsBuilder<Post>(
  response: controller.postsResponse,
  fetchPageData: (reset) => controller.updatePosts(reset: reset),
  
  // whether to turn all the existing cards into loaders or not.
  // If true, all the already displayed items will convert into
  // loaders, and then the new list will be rendered.
  
  // If false, then nothing will change on the screen while the data
  // is being fetched, when the data arrives, the content in the
  // cards will replace.
  showLoaderOnResetGetter: (itemsFetchScope) => [
    ItemsFetchScope.noItemsRefresh,
    ItemsFetchScope.onErrorRefresh,
    ItemsFetchScope.pullDownToRefresh,
  ].contains(itemsFetchScope),

  /// whether to display items in a list or grid view.
  itemsDisplayType: ItemsDisplayType.list,
  
  /// there are params to customize your list / grid view even further.
  /// Read more below...
  itemBuilder: (context, index, item) => Text('Item$index : $item'),
),
```

If the state is handled using PaginationItemsStateHandler, then response and fetchPageData is handled internally
and is provided in the `builder` callback. Use it as follows:
```dart
/// function which calls the API and returns `PaginatedItemsResponse`.
Future<PaginatedItemsResponse<Post>> updatePosts(dynamic paginationKey) async {
  return await PostsRepository.getPosts(startKey: paginationKey);
}

PaginationItemsStateHandler<Post>(
  fetchPageData: updatePosts,
  builder: (response, fetchPageData) {
    return PaginatedItemsBuilder<Post>(
      response: response,
      fetchPageData: fetchPageData,
      itemBuilder: (context, idx, post) => PostCard(post),
      loaderItemsCount: 12,
    );
  },
),
```

You can also log the result directly by using the `log()` function on the `PaginatedItemsResponse`
directly...
```dart
final response = PaginatedItemsResponse<Post>(
  listItems: res.data?.posts,
  paginationKey: res.data?.paginationKey,
  idGetter: (post) => post.id,
);

response.log();
```

## Shimmer loader
Want to use the shimmer loader somewhere else?

What if you have multiple `PaginatedItemsBuilder` widgets in a single view,
then every builder has it's own loader, and you want a pull down refresh
handler on the main page, and at the same time don't want every widget
to render it's own loader, instead, have a common global loader for the entire page.

Then you can use `LoaderShimmer`, which is basically shimmer with the
`ShimmerConfig` properties as defaults, that can also be changed(if required)...
```dart
LoaderShimmer(

  baseColor: Colors.grey, // defaults to `ShimmerConfig.baseColor`

  // ... and more properties

  child: ListView(
    children: [
      // disable individual loaders for these builders by passing false 
      // in the showLoaderOnReset flag in the updateX methods..
      PaginatedItemsBuilder1(),
      PaginatedItemsBuilder2(),
      PaginatedItemsBuilder3(),
    ],
  ),
);
```

## PaginatedItemsBuilder Config

To see the shimmer loader in play, you need to provide a mock items getter.. What basically happens
is that this 'MockItem' is basically an object of the class `T` which is passed in
the `PaginatedItemsBuilder` class.

Generate a class like shown:
```dart
class MockItems {
  static dynamic getByType<T>([String? mockItemKey]) {
    final key = mockItemKey ?? T.toString();
    switch (key) {
      case 'Category':
        // a widget can also be returned from here, instead of an object...
        // if a widget is returned, then widget is rendered directly...
        return _category;
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
  // ...and a lot more params
);
```

## Supporting multiple themes

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

---

# 🎯 Sample Usage

See the [example](https://github.com/rithik-dev/paginated_items_builder/blob/master/example) app for a complete app.

Check out the full API reference for the widget [here](https://pub.dev/documentation/paginated_items_builder/latest/paginated_items_builder/PaginatedItemsBuilder-class.html) and reference for the response [here](https://pub.dev/documentation/paginated_items_builder/latest/paginated_items_builder/PaginatedItemsResponse-class.html).

```dart
import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';
import 'package:paginated_items_builder_demo/controllers/posts_controller.dart';
import 'package:paginated_items_builder_demo/models/post.dart';
import 'package:paginated_items_builder_demo/repositories/posts_repository.dart';
import 'package:paginated_items_builder_demo/widgets/post_card.dart';

class HomeScreen extends StatelessWidget {
  static const id = 'HomeScreen';

  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const PostsListWithStateHandledExternally();
    // return const PostsListWithStateHandledInternally();
  }
}

//******************************************************************
// WITH CONTROLLER
//******************************************************************

class PostsListWithStateHandledExternally extends StatelessWidget {
  const PostsListWithStateHandledExternally({super.key});

  @override
  Widget build(BuildContext context) {
    final postsCon = PostsController.of(context);

    return SafeArea(
      child: Scaffold(
        body: PaginatedItemsBuilder<Post>(
          response: postsCon.postsResponse,
          // whether to turn all the existing cards into loaders or not.
          // If true, all the already displayed items will convert into
          // loaders, and then the new list will be rendered.

          // If false, then nothing will change on the screen while the data
          // is being fetched, when the data arrives, the content in the
          // cards will replace.
          showLoaderOnResetGetter: (itemsFetchScope) => [
            ItemsFetchScope.noItemsRefresh,
            ItemsFetchScope.onErrorRefresh,
            ItemsFetchScope.pullDownToRefresh,
          ].contains(itemsFetchScope),
          fetchPageData: (reset) => postsCon.updatePosts(reset: reset),
          itemBuilder: (context, idx, post) => PostCard(post),
          loaderItemsCount: 12,
        ),
      ),
    );
  }
}

//******************************************************************
// WITHOUT CONTROLLER
//******************************************************************

class PostsListWithStateHandledInternally extends StatelessWidget {
  const PostsListWithStateHandledInternally({super.key});

  /// function which calls the API and returns [PaginatedItemsResponse]
  Future<PaginatedItemsResponse<Post>> updatePosts(
    dynamic paginationKey,
  ) async {
    return await PostsRepository.getPosts(startKey: paginationKey);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PaginationItemsStateHandler<Post>(
          fetchPageData: updatePosts,
          builder: (response, fetchPageData) {
            return PaginatedItemsBuilder<Post>(
              response: response,
              fetchPageData: fetchPageData,
              itemBuilder: (context, _, post) => PostCard(post),
              loaderItemsCount: 12,
            );
          },
        ),
      ),
    );
  }
}
```

---

# 👤 Collaborators


| Name | GitHub | Linkedin |
|-----------------------------------|-------------------------------------|-------------------------------------|
| Rithik Bhandari | [github/rithik-dev](https://github.com/rithik-dev) | [linkedin/rithik-bhandari](https://www.linkedin.com/in/rithik-bhandari) |
