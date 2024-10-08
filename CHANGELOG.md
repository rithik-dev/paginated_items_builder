# [1.2.4]

* Added issue tracker link
* Updated README.md
* Updated example app
* Updated dependencies

# [1.2.3]

* Fixed ShimmerConfig initialization error

# [1.2.2]

* Fixed linter warnings
* Updated dependencies
* Updated config.. (Added more elements in config)

# [1.2.1+1]

* Updated README.md

# [1.2.1]

* Added errorTextGetter in config
* Added customScrollPhysics, bottomLoader param
* Now, can return a widget from mockItemGetter instead of an object, to directly render that widget...

# [1.2.0]

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

# [1.1.0]

* Added error logs
* Optimized initializing PaginatedItemsBuilder
* Added showLoaderOnResetBuilder in PaginationItemsStateHandler to update showLoaderOnReset param for builders with internal state management.
* Updated example app
* Updated README.md

# [1.0.9]

* Added ignore pointer to disable onTap for loaders

# [1.0.8]

* Added isLoading param to LoaderShimmer

# [1.0.7]

* Added some helper getters/functions in PaginatedItemsResponse. 
* Added ItemsFetchScope i.e. defines the scope from which fetchPageData in PaginatedItemsBuilder was called.
* Exposed LoaderShimmer as a widget to wrap around your own widgets.
* Updated noItemsTextGetter definition
* Updated example app
* Updated README.md

# [1.0.6]

* Fixed a bug where fetchData was called twice if PaginationItemsStateHandler was used as parent in release mode (optimization).
* Updated example app

# [1.0.5]

* Added access/update to list elements by using [] syntax on PaginatedItemsResponse directly.
* Added custom refresh icon builder parameter
* Added mockItemKey param for getting mock item with this key, if T is not used.
* Added disable refresh indicator param
* Fixed scroll controller assignment
* Fixed triggering fetchData multiple times by custom implementation. Removed VisibilityDetector as dependency.
* Fixed a bug where fetchData was called twice if PaginationItemsStateHandler was used as parent
* Updated example app
* Updated README.md

# [1.0.4]

* Fixed late initialize error for shimmer direction variable
* Updated README.md

# [1.0.3]

* Exposed shimmer direction property
* Updated docs
* Updated README.md

# [1.0.2]

* Updated default shimmer duration
* Updated README.md

# [1.0.1]

* Updated README.md

# [1.0.0]

* Updated license
* Updated README.md

# [0.0.5]

* Made items in config constructors optional
* Not showing multiple loaders when MockItem not found
* Added remaining field docs
* Added a better example app showing full functionality

# [0.0.4]

* Fixed example app

# [0.0.3]

* Minor README fix

# [0.0.2]

* Fixed web support (removed dart:io import)
* Fixed example app placement
* Fixed formatting for files

# [0.0.1]

* Easier to display items in a list/grid view from your controllers directly or handling state
  internally with support for pagination. Saves the results in state to avoid unnecessary api calls
  everytime screen is pushed.
