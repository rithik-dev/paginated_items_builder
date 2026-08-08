## 2.0.0 - 2026-08-08

* BREAKING: now requires Flutter 3.41.0 or newer and Dart 3.9.0 or newer. Stay on 1.2.5 if you are on an older SDK.
* BREAKING: every `PaginatedItemsResponse` parameter is now required — `idGetter`, `listItems` and `paginationKey`. Each of them failed silently when left out: without `idGetter` a page could duplicate items already in the list and `updateItem` / `findByUid` could not work; without `paginationKey` the list quietly stopped after the first page, because a missing key reads as "no more data". Pass `listItems: null` or `paginationKey: null` explicitly where they do not apply. The analyzer will point out every call that needs updating.
* BREAKING: `PaginatedItemsResponse.items` is no longer nullable, and is now a `final List<T>`. A response that exists always has a list, even an empty one — "nothing fetched yet" is expressed by a null response, which is what `PaginatedItemsBuilder.response` already did. Drop the `!` and the null checks around `items`. `clear()` now empties the list rather than setting it to null, and the `hasData` getter is gone with nothing left for it to distinguish; use `isEmpty` / `isNotEmpty`, or check the response itself for null.
* BREAKING: `operator []` on `PaginatedItemsResponse` now returns a non-nullable item and throws a `RangeError` on a bad index, like a plain `List`, instead of returning null.
* Added `PaginatedItemsResponse.empty()` for holding a response before the first page has been fetched, so starting empty does not mean spelling out two nulls.
* Added `itemsPerPage`, for APIs that page by size rather than by cursor. When set, `hasMoreData` reports whether the last page came back full instead of looking at `paginationKey`, so a list ends when a short page arrives. Leave it unset to keep the existing key-based behaviour.
* Added a `merge()` extension on a nullable response, replacing the `if (reset || response == null) … else response.update(…)` branch every controller was writing by hand. `PaginationItemsStateHandler` and the example controller now use it.
* Added `length`, `isEmpty` and `isNotEmpty` on `PaginatedItemsResponse`.
* Added `hitTestBehavior` and `findItemIndexCallback` to `PaginatedItemsBuilder`, passed through to the underlying list or grid. `findItemIndexCallback` takes an item index in both display modes, so you never have to account for the separators inserted between list items.
* Fixed `noItemsWidgetBuilder`, `errorWidgetBuilder` and `refreshIconBuilder` on `PaginatedItemsBuilderConfig`. They were declared but could never be set, and reading them threw a `LateInitializationError`. They can now be passed to the config and are used as the fallback when the widget does not override them.
* Fixed pagination stalling after a pull-to-refresh. The bottom loader remembered the index it last fetched at, so a refresh that landed on the same list length made it skip loading the next page.
* Fixed `updateItem()` and `findByUid()` throwing after `clear()`.
* Added `updateItems()`, the bulk form of `updateItem()`. It indexes the existing ids once instead of rescanning the list for every item, so prefer it over calling `updateItem()` in a loop. Merging a fetched page now goes through it.
* No longer calls `setState()` after the widget is disposed, so tearing down a screen mid-fetch no longer throws behind a swallowed exception.
* The bottom loader no longer starts a second page fetch while one is already in flight.
* Exported the callback typedefs (`RefreshIconBuilder`, `NoItemsTextGetter`, `NoItemsWidgetBuilder`, `ErrorTextGetter`, `ErrorWidgetBuilder`, `ShowLoaderOnResetGetter`). They were the declared types of public parameters but could not be imported.
* Added `scrollCacheExtent`, matching Flutter's replacement for the deprecated pixels-only `cacheExtent`. The existing `cacheExtent` parameter still works and is converted internally.
* `PaginatedItemsResponse.idGetter` is now a public final field, so a response's id getter can be read back.
* Bumped `flutter_lints` to 6.0.0 and fixed the lints it surfaced.
* Added a test suite covering the response model, the config fallbacks and the pagination behaviour.
* Fixed the `idGetter` snippets in the README, which returned an `int` where a `String` is required.
* Fixed all 30 dartdoc warnings the package emitted, mostly unresolved doc references in the public API.
* Added a migration guide to the README for moving from 1.x.
* Example app: upgraded the Android build to Gradle 8.14.5, AGP 8.11.1, Kotlin 2.2.20 and Java 17. It was on Gradle 8.3, below Flutter's current minimum of 8.7, so `flutter build apk` failed outright.
* Added a screenshot to the package listing, so pub.dev now shows a thumbnail in search results and a gallery on the package page.
* README: dropped a badge that had stopped rendering, swapped in monthly downloads, and added links to the author's portfolio and other packages.
* README: the screenshots are now served from this repository instead of GitHub's attachment CDN, which was outside the repo's control and could have gone stale.

## 1.2.5 - 2026-07-28

* Added GitHub Actions CI to automate version bumps, changelog updates, tagging and pub.dev publishing.

## 1.2.4 - 2024-10-09

* Added issue tracker link
* Updated README.md
* Updated example app
* Updated dependencies

## 1.2.3 - 2022-06-08

* Fixed ShimmerConfig initialization error

## 1.2.2 - 2022-06-07

* Fixed linter warnings
* Updated dependencies
* Updated config.. (Added more elements in config)

## 1.2.1+1 - 2022-04-18

* Updated README.md

## 1.2.1 - 2022-04-18

* Added errorTextGetter in config
* Added customScrollPhysics, bottomLoader param
* Now, can return a widget from mockItemGetter instead of an object, to directly render that widget...

## 1.2.0 - 2022-04-15

* Added a new ItemsFetchScope i.e. onErrorRefresh, which comes in play if an error occurs
* Added error handling in the builder
* Added showLoaderOnResetGetter param on the builder itself
* gridDelegate is now customizable if ItemsDisplayType is grid.
* Fixed LoaderShimmer err for null configs
* Added logErrors param to PaginatedItemsBuilderConfig
* Minor fixes to PaginatedItemsResponse
* Added callbacks for emptyTextBuilder, emptyWidgetBuilder for more customization
* Added callbacks for errorTextBuilder, errorWidgetBuilder for more customization
* Optimizations done to the main widget
* Added check for null response
* Updated pagination items state handler
* Added remaining list/grid view params that can now be passed directly
* Update dart doc comments
* Updated example app
* Fixed README.md

## 1.1.0 - 2022-04-01

* Added error logs
* Optimized initializing PaginatedItemsBuilder
* Added showLoaderOnResetBuilder in PaginationItemsStateHandler to update showLoaderOnReset param for builders with internal state management.
* Updated example app
* Updated README.md

## 1.0.9 - 2022-03-31

* Added ignore pointer to disable onTap for loaders

## 1.0.8 - 2022-03-31

* Added isLoading param to LoaderShimmer

## 1.0.7 - 2022-03-31

* Added some helper getters/functions in PaginatedItemsResponse. 
* Added ItemsFetchScope i.e. defines the scope from which fetchPageData in PaginatedItemsBuilder was called.
* Exposed LoaderShimmer as a widget to wrap around your own widgets.
* Updated noItemsTextGetter definition
* Updated example app
* Updated README.md

## 1.0.6 - 2022-03-29

* Fixed a bug where fetchData was called twice if PaginationItemsStateHandler was used as parent in release mode (optimization).
* Updated example app

## 1.0.5 - 2022-03-29

* Added access/update to list elements by using [] syntax on PaginatedItemsResponse directly.
* Added custom refresh icon builder parameter
* Added mockItemKey param for getting mock item with this key, if T is not used.
* Added disable refresh indicator param
* Fixed scroll controller assignment
* Fixed triggering fetchData multiple times by custom implementation. Removed VisibilityDetector as dependency.
* Fixed a bug where fetchData was called twice if PaginationItemsStateHandler was used as parent
* Updated example app
* Updated README.md

## 1.0.4 - 2022-02-15

* Fixed late initialize error for shimmer direction variable
* Updated README.md

## 1.0.3 - 2022-02-15

* Exposed shimmer direction property
* Updated docs
* Updated README.md

## 1.0.2 - 2022-02-15

* Updated default shimmer duration
* Updated README.md

## 1.0.1 - 2022-02-07

* Updated README.md

## 1.0.0 - 2022-01-26

* Updated license
* Updated README.md

## 0.0.5 - 2022-01-15

* Made items in config constructors optional
* Not showing multiple loaders when MockItem not found
* Added remaining field docs
* Added a better example app showing full functionality

## 0.0.4 - 2022-01-10

* Fixed example app

## 0.0.3 - 2022-01-10

* Minor README fix

## 0.0.2 - 2022-01-10

* Fixed web support (removed dart:io import)
* Fixed example app placement
* Fixed formatting for files

## 0.0.1 - 2021-11-21

* Easier to display items in a list/grid view from your controllers directly or handling state
  internally with support for pagination. Saves the results in state to avoid unnecessary api calls
  everytime screen is pushed.
