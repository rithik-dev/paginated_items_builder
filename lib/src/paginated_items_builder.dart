import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

/// enum used to check how the list items are to be rendered on the screen.
/// Whether in a list view or a grid view.
enum ItemsDisplayType {
  /// Render the items in a list view
  list,

  /// Render the items in a grid view
  grid,
}

/// Handles rendering the items on the screen. Can have [PaginationItemsStateHandler]
/// as parent if state is not handled externally.
class PaginatedItemsBuilder<T> extends StatefulWidget {
  const PaginatedItemsBuilder({
    Key? key,
    required this.fetchPageData,
    required this.response,
    required this.itemBuilder,
    this.itemsDisplayType = ItemsDisplayType.list,
    this.shrinkWrap = false,
    this.reverse = false,
    this.clipBehaviour = Clip.hardEdge,
    this.cacheExtent,
    this.disableRefreshIndicator = false,
    this.logError,
    this.paginate = true,
    this.showRefreshIcon = true,
    this.neverScrollablePhysicsOnShrinkWrap = true,
    this.loader = const Center(
      child: CircularProgressIndicator.adaptive(),
    ),
    this.loaderItemsCount = 10,
    this.scrollController,
    this.gridDelegate,
    this.padding,
    this.emptyTextBuilder,
    this.emptyWidgetBuilder,
    this.errorTextBuilder,
    this.errorWidgetBuilder,
    this.showLoaderOnResetGetter,
    this.maxLength,
    this.refreshIconBuilder,
    this.listSeparatorWidget,
    this.listItemsGap,
    this.gridCrossAxisCount,
    this.gridMainAxisSpacing,
    this.gridCrossAxisSpacing,
    this.gridChildAspectRatio,
    this.scrollDirection = Axis.vertical,
    this.primary,
    this.mockItemKey,
    this.gridSemanticChildCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.restorationId,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  }) : super(key: key);

  /// This is the controller function that should handle fetching the list
  /// and updating in the state.
  ///
  /// The callback value provided is reset, If that is true,
  /// that means an action was triggered which requires to
  /// force reload the items of the list.
  ///
  /// The [reset] flag will be true only when the [itemsFetchScope] is either
  /// [ItemsFetchScope.noItemsRefresh] i.e. no items were found, and user
  /// clicked the refresh icon OR [ItemsFetchScope.pullDownToRefresh] i.e.
  /// the user wants to refresh the list contents with pull-down action. OR
  /// [ItemsFetchScope.onErrorRefresh] if an error occurs.
  ///
  /// If state is handled using [PaginationItemsStateHandler],
  /// then the builder in it provides this argument and should be passed directly.
  final Future<PaginatedItemsResponse<T>?> Function(bool reset) fetchPageData;

  /// Callback function which requires a widget that is rendered for each item.
  /// Provides context, index of the item in the list and the item itself.
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  /// The response object whose contents are displayed.
  ///
  /// If state is handled using [PaginationItemsStateHandler],
  /// then the builder in it provides this argument and should be passed directly.
  final PaginatedItemsResponse<T>? response;

  /// Pass in a custom scroll controller if needed.
  final ScrollController? scrollController;

  /// Scroll direction of the list/grid view
  final Axis scrollDirection;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Defaults to false
  final bool shrinkWrap;

  /// True if you don't want the in-built refresh indicator for your items.
  ///
  /// Defaults to false.
  final bool disableRefreshIndicator;

  /// Whether to log errors to the console or not.
  ///
  /// Defaults to [PaginatedItemsBuilderConfig.logErrors] i.e. true
  final bool? logError;

  /// The amount of space by which to inset the children.
  final EdgeInsets? padding;

  /// Can be used to override [PaginatedItemsBuilderConfig.mockItemGetter] property.
  ///
  /// This is passed in the [PaginatedItemsBuilderConfig.mockItemGetter]'s key
  /// parameter in the callback.
  ///
  /// If [mockItemKey] is provided, then the <T> param in mockItemsGetter is ignored
  /// to get the mock item.
  ///
  /// If [mockItemKey] is null, then [T] is used.
  ///
  /// Should be preferably used if [T] is generic like [String].
  final String? mockItemKey;

  /// Useful when the [PaginatedItemsBuilder] is a child of another scrollable,
  /// then the physics should be [NeverScrollableScrollPhysics] as it conflicts.
  /// Hence, if true, it overrides the [shrinkWrap] property as [shrinkWrap]
  /// should be true if the [PaginatedItemsBuilder] is inside another scrollable
  /// widget.
  final bool neverScrollablePhysicsOnShrinkWrap;

  /// The refresh icon builder. [showRefreshIcon] is ignored if [refreshIconBuilder] is not null;
  /// The parameter provides a function which should be passed to your custom widget's
  /// gesture handler to trigger refreshing the items.
  final Widget Function(void Function() onTap)? refreshIconBuilder;

  /// The text to show if no items are present.
  ///
  /// The value provided is the [mockItemKey].
  /// If [mockItemKey] is null, then [T] is passed.
  ///
  /// Has no effect if [emptyWidgetBuilder] is not null.
  final String? Function(String? typeKey)? emptyTextBuilder;

  /// The widget to display if no items are there to display.
  ///
  /// The first param is the typeKey, i.e. [mockItemKey]
  /// if [mockItemKey] is not null, else [T] is passed.
  ///
  /// The 2nd param is [onTap] which should be passed to the refresh button
  /// to refresh the contents.
  ///
  /// [emptyTextBuilder] has no effect if [emptyWidgetBuilder] is not null.
  final Widget Function(String? typeKey, void Function() onTap)?
      emptyWidgetBuilder;

  /// The text to show if an error occurs.
  ///
  /// The value provided is the error occurred.
  ///
  /// Has no effect if [errorWidgetBuilder] is not null.
  final String? Function(dynamic error)? errorTextBuilder;

  /// The widget to display if an errors.
  ///
  /// The first param is the error occurred.
  ///
  /// The 2nd param is [onTap] which should be passed to the refresh button
  /// to refresh the contents.
  ///
  /// [errorTextBuilder] has no effect if [errorWidgetBuilder] is not null.
  final Widget Function(dynamic error, void Function() onTap)?
      errorWidgetBuilder;

  /// If no items are there to display, shows a refresh icon to again call the
  /// API to update the results.
  final bool showRefreshIcon;

  /// Whether to paginate a specific list of items or not. Defaults to true.
  final bool paginate;

  /// Limits the item count no matter what the length of the content is in the
  /// [PaginatedItemsResponse.items].
  final int? maxLength;

  /// The number of loader widgets to render before the data is fetched for the
  /// first time.
  final int loaderItemsCount;

  /// Whether to display items in a list view or grid view.
  final ItemsDisplayType itemsDisplayType;

  /// The loader to render if [mockItem] not found from [PaginatedItemsBuilderConfig.mockItemGetter].
  final Widget loader;

  /// Whether to switch all the cards to their respective loaders when [reset] is true,
  /// i.e. if the user pulls down to refresh, or no items were found...
  ///
  /// The callback value is the [ItemsFetchScope], which defines the action calling the
  /// fetch data function.
  ///
  /// This callback will only be called if [reset] is true.
  ///
  /// The [reset] flag will be true only when the [itemsFetchScope] is either
  /// [ItemsFetchScope.noItemsRefresh] i.e. no items were found, and user
  /// clicked the refresh icon OR [ItemsFetchScope.pullDownToRefresh] i.e.
  /// the user wants to refresh the list contents with pull-down action OR
  /// if [ItemsFetchScope.onErrorRefresh] if an error occurs..
  ///
  /// By default, the loader will always be shown if reset is true.
  ///
  /// The loader will always show on [ItemsFetchScope.initialLoad], no matter what.
  final bool Function(ItemsFetchScope itemsFetchScope)? showLoaderOnResetGetter;

  /// config
  static PaginatedItemsBuilderConfig? config;

  // -------- params that are passed directly to the list/grid view -------- //

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// The viewport has an area before and after the
  /// visible area to cache items that are about to become visible
  /// when the user scrolls.
  ///
  /// Items that fall in this cache area are laid out even though they are
  /// not (yet) visible on screen. The cacheExtent describes
  /// how many pixels the cache area extends before the leading
  /// edge and after the trailing edge of the viewport.
  ///
  /// The total extent, which the viewport will try to cover with children,
  /// is cacheExtent before the leading edge + extent of the main axis +
  /// cacheExtent after the trailing edge.
  ///
  /// The cache area is also used to implement implicit accessibility
  /// scrolling on iOS: When the accessibility focus moves from an
  /// item in the visible viewport to an invisible item in the cache area,
  /// the framework will bring that item into view with
  /// an (implicit) scroll action.
  final double? cacheExtent;

  /// The content will be clipped (or not) according to this option.
  ///
  /// See the enum Clip for details of all possible options and
  /// their common use cases.
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehaviour;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// When this is true, the scroll view is scrollable even if it does not have
  /// sufficient content to actually scroll. Otherwise, by default the user can
  /// only scroll the view if it has sufficient content. See [physics].
  ///
  /// Also when true, the scroll view is used for default [ScrollAction]s. If a
  /// ScrollAction is not handled by an otherwise focused part of the application,
  /// the ScrollAction will be evaluated using this scroll view, for example,
  /// when executing [Shortcuts] key events like page up and down.
  ///
  /// On iOS, this also identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool? primary;

  /// Whether to wrap each child in an [AutomaticKeepAlive].
  ///
  /// Typically, children in lazy list are wrapped in [AutomaticKeepAlive]
  /// widgets so that children can use [KeepAliveNotification]s to preserve
  /// their state when they would otherwise be garbage collected off-screen.
  ///
  /// This feature (and [addRepaintBoundaries]) must be disabled if the children
  /// are going to manually maintain their [KeepAlive] state. It may also be
  /// more efficient to disable this feature if it is known ahead of time that
  /// none of the children will ever try to keep themselves alive.
  ///
  /// Defaults to true.
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary].
  ///
  /// Typically, children in a scrolling container are wrapped in repaint
  /// boundaries so that they do not need to be repainted as the list scrolls.
  /// If the children are easy to repaint (e.g., solid color blocks or a short
  /// snippet of text), it might be more efficient to not add a repaint boundary
  /// and simply repaint the children during scrolling.
  ///
  /// Defaults to true.
  final bool addRepaintBoundaries;

  /// Whether to wrap each child in an [IndexedSemantics].
  ///
  /// Typically, children in a scrolling container must be annotated with a
  /// semantic index in order to generate the correct accessibility
  /// announcements. This should only be set to false if the indexes have
  /// already been provided by an [IndexedSemantics] widget.
  ///
  /// Defaults to true.
  ///
  /// See also:
  ///
  ///  * [IndexedSemantics], for an explanation of how to manually
  ///    provide semantic indexes.
  final bool addSemanticIndexes;

  /// Restoration ID to save and restore the scroll offset of the scrollable.
  ///
  /// If a restoration id is provided, the scrollable will persist its current
  /// scroll offset and restore it during state restoration.
  ///
  /// The scroll offset is persisted in a RestorationBucket claimed from the
  /// surrounding RestorationScope using the provided restoration ID.
  ///
  ///   * [RestorationManager], which explains how state restoration
  ///   works in Flutter.
  final String? restorationId;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], scrolling drag behavior will begin
  /// at the position where the drag gesture won the arena.
  ///
  /// If set to [DragStartBehavior.down] it will begin at the position
  /// where a down event is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make
  /// drag animation smoother and setting it to [DragStartBehavior.down]
  /// will make drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///   * [DragGestureRecognizer.dragStartBehavior], which gives
  ///   an example for the different behaviors
  final DragStartBehavior dragStartBehavior;

  /// [ScrollViewKeyboardDismissBehavior] the defines how this [ScrollView]
  /// will dismiss the keyboard automatically.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  // -------- list-specific params -------- //

  /// The gap between concurrent list items.
  /// Has no effect if [listSeparatorWidget] is not null.
  final double? listItemsGap;

  /// Separator for items in a list view.
  final Widget? listSeparatorWidget;

  // -------- grid-specific params -------- //

  /// The number of children that will contribute semantic information.
  ///
  /// Some subtypes of [ScrollView] can infer this value automatically. For
  /// example [ListView] will use the number of widgets in the child list,
  /// while the [ListView.separated] constructor will use half that amount.
  ///
  /// For [CustomScrollView] and other types which do not receive a builder
  /// or list of widgets, the child count must be explicitly provided. If the
  /// number is unknown or unbounded this should be left unset or set to null.
  ///
  /// See also:
  ///
  ///  * [SemanticsConfiguration.scrollChildCount], the corresponding semantics property.
  final int? gridSemanticChildCount;

  /// The grid's delegate, controlling the layout of tiles in a grid.
  /// Used if [itemsDisplayType] is [ItemsDisplayType.grid].
  ///
  /// Defaults to [SliverGridDelegateWithFixedCrossAxisCount].
  final SliverGridDelegate? gridDelegate;

  /// The grid axis count for the delegate [SliverGridDelegateWithFixedCrossAxisCount].
  /// Has no effect if [gridDelegate] is not null.
  final int? gridCrossAxisCount;

  /// The grid main axis spacing for the delegate [SliverGridDelegateWithFixedCrossAxisCount].
  /// Has no effect if [gridDelegate] is not null.
  final double? gridMainAxisSpacing;

  /// The grid cross axis spacing for the delegate [SliverGridDelegateWithFixedCrossAxisCount].
  /// Has no effect if [gridDelegate] is not null.
  final double? gridCrossAxisSpacing;

  /// The grid child aspect ratio for the delegate [SliverGridDelegateWithFixedCrossAxisCount].
  /// Has no effect if [gridDelegate] is not null.
  final double? gridChildAspectRatio;

  @override
  _PaginatedItemsBuilderState<T> createState() =>
      _PaginatedItemsBuilderState<T>();
}

class _PaginatedItemsBuilderState<T> extends State<PaginatedItemsBuilder<T>> {
  dynamic _error;

  bool get hasError => _error != null;

  int? _lastLoaderBuiltIndex;

  late bool showMainLoader;
  late bool showBottomLoader;
  late ScrollPhysics? scrollPhysics;
  late int itemCount;
  late T? mockItem;

  late PaginatedItemsBuilderConfig config;

  Future<void> _fetchData({
    bool reset = false,
    required ItemsFetchScope itemsFetchScope,
  }) async {
    setState(() {
      showMainLoader = (itemsFetchScope != ItemsFetchScope.loadMoreData);
      if (reset && widget.showLoaderOnResetGetter != null) {
        showMainLoader = widget.showLoaderOnResetGetter!(itemsFetchScope);
      }
    });

    try {
      final res = await widget.fetchPageData(reset);
      if (res == null) throw Exception('null response');

      _error = null;
    } catch (error, stackTrace) {
      _error = error;

      if (widget.logError ?? config.logErrors) {
        dev.log(
          '\nSomething went wrong! Most probably the fetchPageData failed due to some error! Please handle any possible errors in the fetchPageData call.',
          name: 'PaginationItemsBuilder<$T>',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (showMainLoader) showMainLoader = false;

    try {
      setState(() {});
    } catch (_) {}
  }

  Widget _itemBuilder(context, index) {
    if (!showMainLoader && widget.response?.items != null) {
      // bottom loader
      // passing index only for bottom loader, to update [_lastLoaderBuiltIndex]
      if (widget.response!.items!.length <= index) return _loaderBuilder(index);

      final item = widget.response!.items![index];
      return widget.itemBuilder(context, index, item);
    } else {
      // initial loader
      return _loaderBuilder();
    }
  }

  Widget _loaderBuilder([int? bottomLoaderIdx]) {
    Widget _buildMockItemLoader() {
      final builtMockItem = IgnorePointer(
        child: widget.itemBuilder(context, 0, mockItem!),
      );

      if (bottomLoaderIdx == null) {
        // if index is null, means this loader is being used for initial loading
        // screen. So, not rendering shimmer as their is main shimmer for that.
        return builtMockItem;
      } else {
        // bottom loader
        return LoaderShimmer(child: builtMockItem);
      }
    }

    if (widget.paginate && bottomLoaderIdx != null) {
      if (_lastLoaderBuiltIndex != bottomLoaderIdx) {
        WidgetsBinding.instance?.addPostFrameCallback(
          (_) => _fetchData(itemsFetchScope: ItemsFetchScope.loadMoreData),
        );
        _lastLoaderBuiltIndex = bottomLoaderIdx;
      }
    }

    return mockItem == null ? widget.loader : _buildMockItemLoader();
  }

  Widget _buildRefreshIcon(void Function() onTap) {
    final customRefreshIcon = widget.refreshIconBuilder?.call(onTap);

    if (customRefreshIcon != null) {
      return customRefreshIcon;
    } else if (widget.showRefreshIcon) {
      return IconButton(
        icon: Icon(
          Icons.refresh,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: onTap,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _emptyWidget() {
    void onTap() {
      _fetchData(
        reset: true,
        itemsFetchScope: ItemsFetchScope.noItemsRefresh,
      );
    }

    final itemName = widget.mockItemKey ?? T.toString();

    if (widget.emptyWidgetBuilder != null) {
      return widget.emptyWidgetBuilder!(itemName, onTap);
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.emptyTextBuilder?.call(itemName) ??
                config.noItemsTextGetter(itemName),
            style: config.noItemsTextStyle,
          ),
          _buildRefreshIcon(onTap),
        ],
      ),
    );
  }

  Widget _errorWidget() {
    void onTap() {
      _fetchData(
        reset: true,
        itemsFetchScope: ItemsFetchScope.onErrorRefresh,
      );
    }

    if (widget.errorWidgetBuilder != null) {
      return widget.errorWidgetBuilder!(_error, onTap);
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.errorTextBuilder?.call(_error) ?? 'Something went wrong!',
            style: config.noItemsTextStyle,
          ),
          _buildRefreshIcon(onTap),
        ],
      ),
    );
  }

  @override
  void initState() {
    PaginatedItemsBuilder.config ??=
        PaginatedItemsBuilderConfig.defaultConfig();

    config = PaginatedItemsBuilder.config!;

    mockItem = widget.mockItemKey == null
        ? config.mockItemGetter<T>()
        : config.mockItemGetter(widget.mockItemKey);

    if (widget.shrinkWrap && widget.neverScrollablePhysicsOnShrinkWrap) {
      scrollPhysics = const NeverScrollableScrollPhysics();
    } else {
      scrollPhysics = const AlwaysScrollableScrollPhysics();
    }

    _fetchData(itemsFetchScope: ItemsFetchScope.initialLoad);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // will display bottom loader, as when built,
    // calls fetchData to fetch more data..
    showBottomLoader =
        (widget.paginate && (widget.response?.hasMoreData ?? false));

    // set: itemCount
    (() {
      int _itemsLen = widget.loaderItemsCount;
      if (!showMainLoader) {
        if (widget.response?.items?.length != null) {
          _itemsLen = widget.response!.items!.length;
        }
        _itemsLen += showBottomLoader ? 1 : 0;
      }
      itemCount = widget.maxLength == null
          ? _itemsLen
          : min(_itemsLen, widget.maxLength!);
    })();

    if (showMainLoader) {
      if (mockItem == null) {
        return _loaderBuilder();
      } else {
        return LoaderShimmer(child: _buildItems());
      }
    } else if (hasError) {
      return _errorWidget();
    } else if (widget.response?.items?.isEmpty ?? false) {
      return _emptyWidget();
    } else if (widget.disableRefreshIndicator ||
        widget.shrinkWrap ||
        widget.scrollDirection == Axis.horizontal) {
      return _buildItems();
    } else {
      return RefreshIndicator(
        onRefresh: () async => await _fetchData(
          reset: true,
          itemsFetchScope: ItemsFetchScope.pullDownToRefresh,
        ),
        child: _buildItems(),
      );
    }
  }

  Widget _buildItems() {
    switch (widget.itemsDisplayType) {
      case ItemsDisplayType.list:
        return _buildListView();
      case ItemsDisplayType.grid:
        return _buildGridView();
    }
  }

  ListView _buildListView() {
    return ListView.separated(
      shrinkWrap: widget.shrinkWrap,
      physics: scrollPhysics,
      controller: widget.scrollController,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      primary: widget.primary,
      restorationId: widget.restorationId,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      clipBehavior: widget.clipBehaviour,
      cacheExtent: widget.cacheExtent,
      itemBuilder: _itemBuilder,
      padding: widget.padding,
      separatorBuilder: (_, __) =>
          widget.listSeparatorWidget ??
          SizedBox(
            width: widget.listItemsGap,
            height: widget.listItemsGap,
          ),
      itemCount: itemCount,
    );
  }

  GridView _buildGridView() {
    return GridView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: scrollPhysics,
      controller: widget.scrollController,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      primary: widget.primary,
      restorationId: widget.restorationId,
      semanticChildCount: widget.gridSemanticChildCount,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      clipBehavior: widget.clipBehaviour,
      cacheExtent: widget.cacheExtent,
      itemBuilder: _itemBuilder,
      gridDelegate: widget.gridDelegate ??
          SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: widget.gridChildAspectRatio ?? 1,
            crossAxisCount: widget.gridCrossAxisCount ?? 2,
            mainAxisSpacing: widget.gridMainAxisSpacing ?? 15,
            crossAxisSpacing: widget.gridCrossAxisSpacing ?? 15,
          ),
      padding: widget.padding,
      itemCount: itemCount,
    );
  }
}
