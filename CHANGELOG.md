## [1.0.9] - 31/03/2022

* Added ignore pointer to disable onTap for loaders

## [1.0.8] - 31/03/2022

* Added isLoading param to LoaderShimmer

## [1.0.7] - 31/03/2022

* Added some helper getters/functions in PaginatedItemsResponse. 
* Added ItemsFetchScope i.e. defines the scope from which fetchPageData in PaginatedItemsBuilder was called.
* Exposed LoaderShimmer as a widget to wrap around your own widgets.
* Updated noItemsTextGetter definition
* Updated example app
* Updated README.md

## [1.0.6] - 29/03/2022

* Fixed a bug where fetchData was called twice if PaginationItemsStateHandler was used as parent in release mode (optimization).
* Updated example app

## [1.0.5] - 29/03/2022

* Added access/update to list elements by using [] syntax on PaginatedItemsResponse directly.
* Added custom refresh icon builder parameter
* Added mockItemKey param for getting mock item with this key, if T is not used.
* Added disable refresh indicator param
* Fixed scroll controller assignment
* Fixed triggering fetchData multiple times by custom implementation. Removed VisibilityDetector as dependency.
* Fixed a bug where fetchData was called twice if PaginationItemsStateHandler was used as parent
* Updated example app
* Updated README.md

## [1.0.4] - 15/02/2022

* Fixed late initialize error for shimmer direction variable
* Updated README.md

## [1.0.3] - 15/02/2022

* Exposed shimmer direction property
* Updated docs
* Updated README.md

## [1.0.2] - 15/02/2022

* Updated default shimmer duration
* Updated README.md

## [1.0.1] - 07/02/2022

* Updated README.md

## [1.0.0] - 26/01/2022

* Updated license
* Updated README.md

## [0.0.5] - 15/01/2022

* Made items in config constructors optional
* Not showing multiple loaders when MockItem not found
* Added remaining field docs
* Added a better example app showing full functionality

## [0.0.4] - 10/01/2022

* Fixed example app

## [0.0.3] - 10/01/2022

* Minor README fix

## [0.0.2] - 10/01/2022

* Fixed web support (removed dart:io import)
* Fixed example app placement
* Fixed formatting for files

## [0.0.1] - 10/01/2022

* Easier to display items in a list/grid view from your controllers directly or handling state
  internally with support for pagination. Saves the results in state to avoid unnecessary api calls
  everytime screen is pushed.
