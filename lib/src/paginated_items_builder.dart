import 'dart:math';

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
    this.disableRefreshIndicator = false,
    this.paginate = true,
    this.showRefreshIcon = true,
    this.neverScrollablePhysicsOnShrinkWrap = true,
    this.loader = const Center(
      child: CircularProgressIndicator.adaptive(),
    ),
    this.loaderItemsCount = 6,
    this.scrollController,
    this.padding,
    this.emptyText,
    this.maxLength,
    this.refreshIconBuilder,
    this.separatorWidget,
    this.listItemsGap,
    this.gridCrossAxisCount,
    this.gridMainAxisSpacing,
    this.gridCrossAxisSpacing,
    this.gridChildAspectRatio,
    this.scrollDirection = Axis.vertical,
    this.mockItemKey,
  }) : super(key: key);

  /// This is the controller function that should handle fetching the list
  /// and updating in the state.
  ///
  /// It provides 2 callback values, first one being the [reset] flag(boolean).
  /// If that is true, that means an action was triggered which requires to
  /// force reload the items of the list.
  ///
  /// The 2nd value is the [ItemsFetchScope], which defines the action calling the
  /// fetch data function.
  ///
  /// The [reset] flag will be true only when the [itemsFetchScope] is either
  /// [ItemsFetchScope.noItemsRefresh] i.e. no items were found, and user
  /// clicked the refresh icon OR [ItemsFetchScope.pullDownToRefresh] i.e.
  /// the user wants to refresh the list contents with pull-down action.
  ///
  /// If state is handled using [PaginationItemsStateHandler],
  /// then the builder in it provides this argument and should be passed directly.
  final Future<void> Function(bool reset, ItemsFetchScope itemsFetchScope)
      fetchPageData;

  /// Callback function which requires a widget that is rendered for each item.
  /// Provides context, index of the item in the list and the item itself.
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  /// The response object whose contents are displayed.
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

  /// The amount of space by which to inset the children.
  final EdgeInsets? padding;

  /// Can be used to override [mockItemsGetter] property.
  /// If [mockItemKey] is provided, then the <T> param in mockItemsGetter is ignored
  /// to get the mock item.
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
  final String? emptyText;

  /// If no items are there to display, shows a refresh icon to again call the
  /// API to update the results.
  final bool showRefreshIcon;

  /// Whether to paginate a specific list of items or not. Defaults to true.
  final bool paginate;

  /// Separator for items in a list view.
  final Widget? separatorWidget;

  /// Limits the item count no matter what the length of the content is in the
  /// [response.items].
  final int? maxLength;

  /// The number of loader widgets to render before the data is fetched for the
  /// first time.
  final int loaderItemsCount;

  /// Whether to display items in a list view or grid view.
  final ItemsDisplayType itemsDisplayType;

  /// The loader to render if mockItem not found from [PaginatedItemsBuilderConfig].
  final Widget loader;

  /// config
  static PaginatedItemsBuilderConfig? config;

  /// The gap between concurrent list items.
  /// Has no effect if [separatorWidget] is not null.
  final double? listItemsGap;

  // grid
  final int? gridCrossAxisCount;
  final double? gridMainAxisSpacing;
  final double? gridCrossAxisSpacing;
  final double? gridChildAspectRatio;

  @override
  _PaginatedItemsBuilderState<T> createState() =>
      _PaginatedItemsBuilderState<T>();
}

class _PaginatedItemsBuilderState<T> extends State<PaginatedItemsBuilder<T>> {
  bool _initialLoading = true;
  bool _loadingMoreData = false;

  int? _lastLoaderBuiltIndex;

  late bool showLoader;
  late ScrollPhysics? scrollPhysics;
  late int itemCount;
  late T? mockItem;

  Future<void> _fetchData({
    bool reset = false,
    required ItemsFetchScope itemsFetchScope,
  }) async {
    if (!mounted) return;
    if (!reset &&
        (widget.response != null &&
            !widget.response!.hasMoreData &&
            !_loadingMoreData)) return;
    setState(() {
      // if (_initialLoading) {
      //   _initialLoading = false;
      // } else
      if (reset) {
        _initialLoading = true;
      } else {
        _loadingMoreData = true;
      }
    });

    try {
      await widget.fetchPageData(reset, itemsFetchScope);
    } catch (_) {}

    if (_initialLoading) _initialLoading = false;
    if (_loadingMoreData) _loadingMoreData = false;
    try {
      setState(() {});
    } catch (_) {}
  }

  Widget _itemBuilder(context, index) {
    if (widget.response?.items != null) {
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

  Widget _loaderBuilder([int? index]) {
    Widget _buildMockItemLoader() {
      final builtMockItem = widget.itemBuilder(context, 0, mockItem!);

      if (index == null) {
        // if index is null, means this loader is being used for initial loading
        // screen. So, not rendering shimmer as their is main shimmer for that.
        return builtMockItem;
      } else {
        // bottom loader
        return LoaderShimmer(child: builtMockItem);
      }
    }

    if (widget.paginate && index != null) {
      if (_lastLoaderBuiltIndex != index) {
        WidgetsBinding.instance?.addPostFrameCallback(
          (_) => _fetchData(itemsFetchScope: ItemsFetchScope.loadMoreData),
        );
        _lastLoaderBuiltIndex = index;
      }
    }

    return mockItem == null ? widget.loader : _buildMockItemLoader();
  }

  Widget _emptyWidget([String? text]) {
    final customRefreshIcon = widget.refreshIconBuilder?.call(
      () => _fetchData(
        reset: true,
        itemsFetchScope: ItemsFetchScope.noItemsRefresh,
      ),
    );

    final itemName = widget.mockItemKey ?? T.toString();

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text ?? PaginatedItemsBuilder.config!.noItemsTextGetter(itemName),
            style: PaginatedItemsBuilder.config!.noItemsTextStyle,
          ),
          if (customRefreshIcon != null)
            customRefreshIcon
          else if (widget.showRefreshIcon)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () => _fetchData(
                reset: true,
                itemsFetchScope: ItemsFetchScope.noItemsRefresh,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    final _config = PaginatedItemsBuilder.config;

    mockItem = widget.mockItemKey == null
        ? _config?.mockItemGetter<T>()
        : _config?.mockItemGetter(widget.mockItemKey);

    final itemsStateHandlerAsParent =
        context.findAncestorWidgetOfExactType<PaginationItemsStateHandler<T>>();
    if (itemsStateHandlerAsParent == null) {
      _fetchData(itemsFetchScope: ItemsFetchScope.initialLoad);
    }

    PaginatedItemsBuilder.config ??=
        PaginatedItemsBuilderConfig.defaultConfig();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    showLoader = (widget.paginate && (widget.response?.hasMoreData ?? false));
    scrollPhysics =
        (widget.shrinkWrap && widget.neverScrollablePhysicsOnShrinkWrap)
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics();
    (() {
      final _itemsLen =
          (widget.response?.items?.length ?? widget.loaderItemsCount) +
              (showLoader ? 1 : 0);
      itemCount = widget.maxLength == null
          ? _itemsLen
          : min(_itemsLen, widget.maxLength!);
    })();

    if (widget.response?.items?.isEmpty ?? false) {
      return _emptyWidget(widget.emptyText);
    } else if (widget.response?.items == null && mockItem == null) {
      return _loaderBuilder();
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
    final itemsView = widget.itemsDisplayType == ItemsDisplayType.list
        ? _buildListView()
        : _buildGridView();

    if (widget.response?.items == null && mockItem != null) {
      return LoaderShimmer(child: itemsView);
    } else {
      return itemsView;
    }
  }

  ListView _buildListView() {
    return ListView.separated(
      shrinkWrap: widget.shrinkWrap,
      physics: scrollPhysics,
      controller: widget.scrollController,
      scrollDirection: widget.scrollDirection,
      itemBuilder: _itemBuilder,
      padding: widget.padding,
      separatorBuilder: (_, __) =>
          widget.separatorWidget ??
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
      scrollDirection: widget.scrollDirection,
      itemBuilder: _itemBuilder,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
