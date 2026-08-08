<!-- Pending release notes. The release workflow moves these into CHANGELOG.md under the new version heading, then clears this file. Write them for the people who use this package, using the same `* entry` bullet style as CHANGELOG.md. This file lives under .github/ so it never ships to pub.dev. -->

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
