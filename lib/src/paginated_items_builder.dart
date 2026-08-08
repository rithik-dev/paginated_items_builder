import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ErrorWidgetBuilder;
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:paginated_items_builder/paginated_items_builder.dart';

/// enum used to check how the items are to be rendered on the screen.
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
    super.key,
    required this.fetchPageData,
    required this.response,
    required this.itemBuilder,
    this.cacheExtent,
    this.scrollCacheExtent,
    this.logErrors,
    this.customScrollPhysics,
    this.scrollController,
    this.gridDelegate,
    this.padding,
    this.noItemsTextGetter,
    this.noItemsWidgetBuilder,
    this.errorTextGetter,
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
    this.primary,
    this.mockItemKey,
    this.gridSemanticChildCount,
    this.restorationId,
    this.noItemsTextStyle,
    this.errorTextStyle,
    this.loader,
    this.bottomLoader,
    this.paginate = true,
    this.showRefreshIcon = true,
    this.neverScrollablePhysicsOnShrinkWrap = true,
    this.itemsDisplayType = ItemsDisplayType.list,
    this.shrinkWrap = false,
    this.reverse = false,
    this.disableLoaderOnTaps = true,
    this.clipBehaviour = Clip.hardEdge,
    this.disableRefreshIndicator = false,
    this.loaderItemsCount = 10,
    this.scrollDirection = Axis.vertical,
    this.ignoreMockItemGetter = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.findItemIndexCallback,
  });

  /// This is the controller function that should handle fetching the list
  /// and updating in the state.
  ///
  /// The callback value provided is reset, If that is true,
  /// that means an action was triggered which requires to
  /// force reload the items of the list.
  ///
  /// The `reset` flag will be true only when the `itemsFetchScope` is either
  /// [ItemsFetchScope.noItemsRefresh] i.e. no items were found, and user
  /// clicked the refresh icon OR [ItemsFetchScope.pullDownToRefresh] i.e.
  /// the user wants to refresh the list contents with pull-down action. OR
  /// [ItemsFetchScope.onErrorRefresh] if an error occurs.
  ///
  /// If state is handled using [PaginationItemsStateHandler],
  /// then the builder in it provides this argument and should be passed directly.
  ///
  /// NOTE: If null is returned from [fetchPageData], then an exception will be thrown..
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

  /// {@template logErrors}
  ///
  /// Whether to log errors to the console or not.
  ///
  /// Defaults to [PaginatedItemsBuilderConfig.logErrors] i.e. true
  ///
  /// {@endtemplate}
  final bool? logErrors;

  /// {@template padding}
  ///
  /// The amount of space by which to inset the children.
  ///
  /// Defaults to [PaginatedItemsBuilderConfig.padding]
  ///
  /// {@endtemplate}
  final EdgeInsets? padding;

  /// Can be used to override [PaginatedItemsBuilderConfig.mockItemGetter] property.
  ///
  /// This is passed in the [PaginatedItemsBuilderConfig.mockItemGetter]'s key
  /// parameter in the callback.
  ///
  /// If [PaginatedItemsBuilder.mockItemKey] is provided, then the `T` param in mockItemsGetter
  /// is ignored to get the mock item.
  ///
  /// If [PaginatedItemsBuilder.mockItemKey] is null, then `T` is used.
  ///
  /// Should be preferably used if `T` is generic like [String].
  final String? mockItemKey;

  /// Useful when the [PaginatedItemsBuilder] is a child of another scrollable,
  /// then the physics should be [NeverScrollableScrollPhysics] as it conflicts.
  /// Hence, if true, it overrides the [shrinkWrap] property as [shrinkWrap]
  /// should be true if the [PaginatedItemsBuilder] is inside another scrollable
  /// widget.
  ///
  /// Has no effect if [customScrollPhysics] is not null.
  final bool neverScrollablePhysicsOnShrinkWrap;

  /// {@template refreshIconBuilder}
  ///
  /// The refresh icon builder. [PaginatedItemsBuilder.showRefreshIcon] is
  /// ignored if [refreshIconBuilder] is not null;
  ///
  /// The parameter provides a function which should be passed to your custom
  /// widget's gesture handler to trigger refreshing the items.
  ///
  /// {@endtemplate}
  final RefreshIconBuilder? refreshIconBuilder;

  /// {@template noItemsTextGetter}
  ///
  /// The text to show if no items are present.
  ///
  /// The value provided is the [PaginatedItemsBuilder.mockItemKey].
  /// If [PaginatedItemsBuilder.mockItemKey] is null, then `T` is passed.
  ///
  /// Has no effect if [noItemsWidgetBuilder] is not null.
  ///
  /// {@endtemplate}
  final NoItemsTextGetter? noItemsTextGetter;

  /// {@template noItemsWidgetBuilder}
  ///
  /// The widget to display if no items are there to display.
  ///
  /// The first param is the typeKey, i.e. [PaginatedItemsBuilder.mockItemKey]
  /// if [PaginatedItemsBuilder.mockItemKey] is not null, else `T` is passed.
  ///
  /// The 2nd param is `refreshOnTap` which should be passed to the refresh
  /// button to refresh the contents.
  ///
  /// [noItemsTextGetter] has no effect if [noItemsWidgetBuilder] is not null.
  ///
  /// {@endtemplate}
  final NoItemsWidgetBuilder? noItemsWidgetBuilder;

  /// {@template noItemsTextStyle}
  ///
  /// Customize the style of the text that is rendered when there
  /// are no items to display.
  ///
  /// Defaults to [PaginatedItemsBuilderConfig.noItemsTextStyle].
  ///
  /// {@endtemplate}
  final TextStyle? noItemsTextStyle;

  /// {@template errorTextGetter}
  ///
  /// The text to show if an error occurs.
  ///
  /// The value provided is the error occurred.
  ///
  /// Has no effect if [errorWidgetBuilder] is not null.
  ///
  /// {@endtemplate}
  final ErrorTextGetter? errorTextGetter;

  /// {@template errorWidgetBuilder}
  /// The widget to display if an errors.
  ///
  /// The first param is the error occurred.
  ///
  /// The 2nd param is `refreshOnTap` which should be passed to the refresh
  /// button to refresh the contents.
  ///
  /// [errorTextGetter] has no effect if [errorWidgetBuilder] is not null.
  ///
  /// {@endtemplate}
  final ErrorWidgetBuilder? errorWidgetBuilder;

  /// {@template errorTextStyle}
  ///
  /// Customize the style of the text that is rendered when an error occurs.
  ///
  /// Defaults to [PaginatedItemsBuilderConfig.errorTextStyle].
  ///
  /// {@endtemplate}
  final TextStyle? errorTextStyle;

  /// Whether to disable onTap gesture events on loaders, when shown...
  ///
  /// Defaults to true
  final bool disableLoaderOnTaps;

  /// If no items are there to display, shows a refresh icon to again call the
  /// API to update the results.
  final bool showRefreshIcon;

  /// Whether to paginate a specific list of items or not. Defaults to true.
  final bool paginate;

  /// Limits the item count no matter what the length of the content is in the
  /// [PaginatedItemsResponse.items].
  ///
  /// Has no effect if the length of the response items is less than [maxLength].
  final int? maxLength;

  /// The number of loader widgets to render before the data is
  /// fetched for the first time.
  final int loaderItemsCount;

  /// Whether to display items in a list view or grid view.
  final ItemsDisplayType itemsDisplayType;

  /// If true, then [PaginatedItemsBuilderConfig.mockItemGetter] will not be
  /// called whatsoever, and mock item remains null...
  final bool ignoreMockItemGetter;

  /// {@template loader}
  ///
  /// The full-screen loader to render if `mockItem` not
  /// found from [PaginatedItemsBuilderConfig.mockItemGetter] or
  /// [PaginatedItemsBuilder.ignoreMockItemGetter] is true.
  ///
  /// {@endtemplate}
  final Widget? loader;

  /// {@template bottomLoader}
  ///
  /// The bottom-loader to render if `mockItem` not
  /// found from [PaginatedItemsBuilderConfig.mockItemGetter] or
  /// [PaginatedItemsBuilder.ignoreMockItemGetter] is true.
  ///
  /// {@endtemplate}
  final Widget? bottomLoader;

  /// {@template showLoaderOnResetGetter}
  ///
  /// Whether to switch all the cards to their respective loaders when `reset` is true,
  /// i.e. if the user pulls down to refresh, or no items were found...
  ///
  /// The callback value is the [ItemsFetchScope], which defines the action calling the
  /// fetch data function.
  ///
  /// This callback will only be called if `reset` is true.
  ///
  /// The `reset` flag will be true only when the `itemsFetchScope` is either
  /// [ItemsFetchScope.noItemsRefresh] i.e. no items were found, and user
  /// clicked the refresh icon OR [ItemsFetchScope.pullDownToRefresh] i.e.
  /// the user wants to refresh the list contents with pull-down action OR
  /// if [ItemsFetchScope.onErrorRefresh] if an error occurs..
  ///
  /// By default, the loader will show if `itemsFetchScope` is either
  /// [ItemsFetchScope.noItemsRefresh] or [ItemsFetchScope.onErrorRefresh]..
  ///
  /// The loader will always show on [ItemsFetchScope.initialLoad], no matter what.
  ///
  /// Defaults to [PaginatedItemsBuilderConfig.showLoaderOnResetGetter].
  ///
  /// {@endtemplate}
  final ShowLoaderOnResetGetter? showLoaderOnResetGetter;

  /// {@template customScrollPhysics}
  ///
  /// How the scroll view should respond to user input.
  ///
  /// If not null, the refresh indicator might not work as expected.
  ///
  /// If you want to use your own refresh indicator outside of this widget,
  /// pass [PaginatedItemsBuilder.disableRefreshIndicator] as true.
  ///
  /// If not null, [PaginatedItemsBuilder.neverScrollablePhysicsOnShrinkWrap] is ignored.
  ///
  /// See also:
  ///
  ///   * [PaginatedItemsBuilderConfig.customScrollPhysics]
  ///
  /// {@endtemplate}
  final ScrollPhysics? customScrollPhysics;

  /// The overall config, that can be used to set some variables
  /// across all instances of [PaginatedItemsBuilder].
  ///
  /// But if a value is passed to [PaginatedItemsBuilder], then it overrides
  /// any value in the config..
  ///
  /// For ex, if [PaginatedItemsBuilderConfig.logErrors] is true,
  /// and [PaginatedItemsBuilder.logErrors] is null, then
  /// [logErrors] is true.
  ///
  /// But if [PaginatedItemsBuilder.logErrors] is not null, then
  /// [PaginatedItemsBuilderConfig.logErrors] is ignored, and
  /// [logErrors] will be the same as [PaginatedItemsBuilder.logErrors].
  static PaginatedItemsBuilderConfig? config;

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
  /// Since internally for list items, [ListView.separated] is being used,
  /// hence, this value is not available for list items.
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
  ///
  /// Expressed in pixels. Ignored if [scrollCacheExtent] is not null.
  final double? cacheExtent;

  /// The cache area of the viewport, expressed as a [ScrollCacheExtent].
  ///
  /// Takes precedence over [cacheExtent], which is the older pixels-only form
  /// of the same setting. Prefer this one — it can also express the cache area
  /// in viewports or as a fixed number of items.
  final ScrollCacheExtent? scrollCacheExtent;

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
  /// only scroll the view if it has sufficient content. See `physics`.
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
  /// [PaginatedItemsBuilder.scrollController] is null.
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

  /// How the gesture detector of the underlying scrollable should behave
  /// during hit testing.
  ///
  /// [HitTestBehavior.opaque] stops widgets behind the list from receiving
  /// events.
  ///
  /// Defaults to [HitTestBehavior.opaque], matching [ScrollView].
  final HitTestBehavior hitTestBehavior;

  /// Finds the index of an item by its key, so the list can keep the state of
  /// items that move rather than rebuilding them from scratch.
  ///
  /// Useful when items are inserted or reordered: without it, a widget whose
  /// position changed is treated as a new child and loses its state.
  ///
  /// The index is an **item** index, matching the one given to [itemBuilder].
  /// It is never a child index, so there is no need to account for the
  /// separators that [ItemsDisplayType.list] inserts between items.
  final ChildIndexGetter? findItemIndexCallback;

  @override
  State<PaginatedItemsBuilder<T>> createState() => _PaginatedItemsBuilderState<T>();
}

class _PaginatedItemsBuilderState<T> extends State<PaginatedItemsBuilder<T>> {
  dynamic _error;

  bool get hasError => _error != null;

  int? _lastLoaderBuiltIndex;

  bool _isFetching = false;

  late bool showMainLoader;
  late bool showBottomLoader;
  late int itemCount;
  late ScrollPhysics scrollPhysics;
  dynamic mockItem;
  late PaginatedItemsBuilderConfig config;

  Future<void> _fetchData({
    bool reset = false,
    required ItemsFetchScope itemsFetchScope,
  }) async {
    _isFetching = true;

    setState(() {
      showMainLoader = (itemsFetchScope != ItemsFetchScope.loadMoreData);
      if (reset) {
        _lastLoaderBuiltIndex = null;

        if (widget.showLoaderOnResetGetter != null) {
          showMainLoader = widget.showLoaderOnResetGetter!(itemsFetchScope);
        } else {
          showMainLoader = config.showLoaderOnResetGetter(itemsFetchScope);
        }
      }
    });

    try {
      final res = await widget.fetchPageData(reset);
      if (res == null) throw Exception('null response');

      _error = null;
    } catch (error, stackTrace) {
      _error = error;

      if (widget.logErrors ?? config.logErrors) {
        dev.log(
          '\nSomething went wrong! Most probably the fetchPageData failed due to some error! Please handle any possible errors in the fetchPageData call.',
          name: 'PaginationItemsBuilder<$T>',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (showMainLoader) showMainLoader = false;

    _isFetching = false;

    if (!mounted) return;
    setState(() {});
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final response = widget.response;

    if (!showMainLoader && response != null) {
      // bottom loader
      // passing index only for bottom loader, to update [_lastLoaderBuiltIndex]
      if (response.items.length <= index) return _loaderBuilder(index);

      return widget.itemBuilder(context, index, response.items[index]);
    } else {
      // initial loader
      return _loaderBuilder();
    }
  }

  Widget _loaderBuilder([int? bottomLoaderIdx]) {
    Widget buildMockItemLoader() {
      final mockItemWidget = mockItem is Widget ? mockItem! : widget.itemBuilder(context, 0, mockItem!);

      final builtMockItem = widget.disableLoaderOnTaps ? IgnorePointer(child: mockItemWidget) : mockItemWidget;

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
      if (_lastLoaderBuiltIndex != bottomLoaderIdx && !_isFetching) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _fetchData(itemsFetchScope: ItemsFetchScope.loadMoreData);
        });
        _lastLoaderBuiltIndex = bottomLoaderIdx;
      }
    }

    final loader = widget.loader ?? config.loader;
    final bottomLoader = widget.bottomLoader ?? config.bottomLoader;

    return mockItem == null ? (bottomLoaderIdx == null ? loader : bottomLoader) : buildMockItemLoader();
  }

  Widget _buildRefreshIcon(VoidCallback refreshOnTap) {
    final refreshIconBuilder = widget.refreshIconBuilder ?? config.refreshIconBuilder;

    if (refreshIconBuilder != null) {
      return refreshIconBuilder(refreshOnTap);
    } else if (widget.showRefreshIcon) {
      return IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: refreshOnTap,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _noItemsWidget() {
    void onTap() {
      _fetchData(reset: true, itemsFetchScope: ItemsFetchScope.noItemsRefresh);
    }

    final itemName = widget.mockItemKey ?? T.toString();

    final noItemsWidgetBuilder = widget.noItemsWidgetBuilder ?? config.noItemsWidgetBuilder;

    if (noItemsWidgetBuilder != null) {
      return noItemsWidgetBuilder(itemName, onTap);
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.noItemsTextGetter?.call(itemName) ?? config.noItemsTextGetter(itemName),
            style: widget.noItemsTextStyle ?? config.noItemsTextStyle,
          ),
          _buildRefreshIcon(onTap),
        ],
      ),
    );
  }

  Widget _errorWidget() {
    void onTap() {
      _fetchData(reset: true, itemsFetchScope: ItemsFetchScope.onErrorRefresh);
    }

    final errorWidgetBuilder = widget.errorWidgetBuilder ?? config.errorWidgetBuilder;

    if (errorWidgetBuilder != null) {
      return errorWidgetBuilder(_error, onTap);
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.errorTextGetter?.call(_error) ?? config.errorTextGetter(_error),
            style: widget.errorTextStyle ?? config.errorTextStyle,
          ),
          _buildRefreshIcon(onTap),
        ],
      ),
    );
  }

  void _initState() {
    PaginatedItemsBuilder.config ??= PaginatedItemsBuilderConfig();

    config = PaginatedItemsBuilder.config!;

    if (widget.ignoreMockItemGetter) {
      mockItem = null;
    } else {
      mockItem = widget.mockItemKey == null ? config.mockItemGetter<T>() : config.mockItemGetter(widget.mockItemKey);
    }

    if (widget.customScrollPhysics != null) {
      scrollPhysics = widget.customScrollPhysics!;
    } else if (config.customScrollPhysics != null) {
      scrollPhysics = config.customScrollPhysics!;
    } else if (widget.shrinkWrap && widget.neverScrollablePhysicsOnShrinkWrap) {
      scrollPhysics = const NeverScrollableScrollPhysics();
    } else {
      scrollPhysics = const AlwaysScrollableScrollPhysics();
    }
  }

  @override
  void initState() {
    super.initState();

    _initState();
    _fetchData(itemsFetchScope: ItemsFetchScope.initialLoad);
  }

  @override
  Widget build(BuildContext context) {
    // init some variables used in initState on every build,
    // so don't have to hot-restart on every change during development...
    if (kDebugMode) _initState();

    // bottom loader is always built, as when rendered in view,
    // calls _fetchData to fetch more data..
    showBottomLoader = widget.paginate && (widget.response?.hasMoreData ?? false);

    // set: itemCount
    (() {
      int itemsLen = widget.loaderItemsCount;
      if (!showMainLoader) {
        final response = widget.response;
        if (response != null) itemsLen = response.items.length;
        itemsLen += showBottomLoader ? 1 : 0;
      }
      itemCount = widget.maxLength == null ? itemsLen : min(itemsLen, widget.maxLength!);
    })();

    if (showMainLoader) {
      if (mockItem == null) {
        return _loaderBuilder();
      } else {
        return LoaderShimmer(child: _buildItems());
      }
    } else if (hasError) {
      return _errorWidget();
    } else if (widget.response?.items.isEmpty ?? false) {
      return _noItemsWidget();
    } else if (widget.disableRefreshIndicator || widget.shrinkWrap || widget.scrollDirection == Axis.horizontal) {
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

  /// Flutter deprecated the pixels-only `cacheExtent` in favour of
  /// [ScrollCacheExtent]. The older [PaginatedItemsBuilder.cacheExtent] is
  /// still honoured by converting it here, so only the current API is used
  /// against the framework.
  ScrollCacheExtent? get _effectiveScrollCacheExtent {
    final scrollCacheExtent = widget.scrollCacheExtent;
    if (scrollCacheExtent != null) return scrollCacheExtent;

    final cacheExtent = widget.cacheExtent;
    return cacheExtent == null ? null : ScrollCacheExtent.pixels(cacheExtent);
  }

  // TODO: add slivers support
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
      scrollCacheExtent: _effectiveScrollCacheExtent,
      hitTestBehavior: widget.hitTestBehavior,
      findItemIndexCallback: widget.findItemIndexCallback,
      itemBuilder: _itemBuilder,
      padding: widget.padding ?? config.padding,
      separatorBuilder: (_, _) =>
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
      scrollCacheExtent: _effectiveScrollCacheExtent,
      hitTestBehavior: widget.hitTestBehavior,
      findChildIndexCallback: widget.findItemIndexCallback,
      itemBuilder: _itemBuilder,
      gridDelegate:
          widget.gridDelegate ??
          SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: widget.gridChildAspectRatio ?? 1,
            crossAxisCount: widget.gridCrossAxisCount ?? 2,
            mainAxisSpacing: widget.gridMainAxisSpacing ?? 15,
            crossAxisSpacing: widget.gridCrossAxisSpacing ?? 15,
          ),
      padding: widget.padding ?? config.padding,
      itemCount: itemCount,
    );
  }
}
