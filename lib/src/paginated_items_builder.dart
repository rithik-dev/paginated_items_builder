import 'dart:math';

import 'package:flutter/material.dart';
import 'package:paginated_items_builder/src/models/paginated_items_builder_config.dart';
import 'package:paginated_items_builder/src/models/paginated_items_response.dart';
import 'package:paginated_items_builder/src/pagination_items_state_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
    this.separatorWidget,
    this.listItemsGap,
    this.gridCrossAxisCount,
    this.gridMainAxisSpacing,
    this.gridCrossAxisSpacing,
    this.gridChildAspectRatio,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);

  /// This is the controller function that should handle fetching the list
  /// and updating in the state.
  ///
  /// The boolean in the callback is the reset flag. If that is true, that means
  /// either the user wants to refresh the list with pull-down refresh, or no items
  /// were found, and user clicked the refresh icon.
  ///
  /// If state is handled using [PaginationItemsStateHandler],
  /// then the builder in it provides this argument and should be passed directly.
  final Future<void> Function(bool reset) fetchPageData;

  /// Callback function which requires a widget that is rendered for each item.
  /// Provides context, index of the item in the list and the item itself.
  final Widget Function(BuildContext, int, T) itemBuilder;

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

  /// The amount of space by which to inset the children.
  final EdgeInsets? padding;

  /// Useful when the [PaginatedItemsBuilder] is a child of another scrollable,
  /// then the physics should be [NeverScrollableScrollPhysics] as it conflicts.
  /// Hence, if true, it overrides the [shrinkWrap] property as [shrinkWrap]
  /// should be true if the [PaginatedItemsBuilder] is inside another scrollable
  /// widget.
  final bool neverScrollablePhysicsOnShrinkWrap;

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
  late final ScrollController _scrollController;

  bool _initialLoading = true;
  bool _loadingMoreData = false;

  final _loaderKey = UniqueKey();

  late bool showLoader;
  late ScrollController? itemsScrollController;
  late ScrollPhysics? scrollPhysics;
  late int itemCount;
  late T? mockItem;

  Future<void> fetchData({bool reset = false}) async {
    if (!mounted) return;
    if (!reset &&
        (widget.response != null &&
            !widget.response!.hasMoreData &&
            !_loadingMoreData)) return;
    setState(() {
      if (_initialLoading) {
        _initialLoading = false;
      } else if (reset) {
        _initialLoading = true;
      } else {
        _loadingMoreData = true;
      }
    });

    try {
      await widget.fetchPageData(reset);
    } catch (_) {}

    if (_initialLoading) _initialLoading = false;
    if (_loadingMoreData) _loadingMoreData = false;
    try {
      setState(() {});
    } catch (_) {}
  }

  Widget _itemBuilder(context, index) {
    if (widget.response?.items != null) {
      if (widget.response!.items!.length <= index) return _loaderBuilder();
      final item = widget.response!.items![index];
      return widget.itemBuilder(context, index, item);
    } else {
      return _loaderBuilder();
    }
  }

  Widget _loaderBuilder() {
    Widget _buildLoader() => mockItem != null
        ? Shimmer.fromColors(
            highlightColor:
                PaginatedItemsBuilder.config!.shimmerConfig.highlightColor,
            baseColor: PaginatedItemsBuilder.config!.shimmerConfig.baseColor,
            period: PaginatedItemsBuilder.config!.shimmerConfig.period,
            child: IgnorePointer(
              child: widget.itemBuilder(context, 0, mockItem!),
            ),
          )
        : widget.loader;

    return widget.paginate
        ? VisibilityDetector(
            key: _loaderKey,
            onVisibilityChanged: (_) => fetchData(),
            child: _buildLoader(),
          )
        : _buildLoader();
  }

  Widget _emptyWidget([String? text]) {
    final itemName = T.toString().toLowerCase().replaceAll('lean', '');
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text ?? PaginatedItemsBuilder.config!.noItemsTextGetter(itemName),
            style: PaginatedItemsBuilder.config!.noItemsTextStyle,
          ),
          if (widget.showRefreshIcon)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () => fetchData(reset: true),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _scrollController = widget.scrollController ?? ScrollController();

    mockItem = PaginatedItemsBuilder.config?.mockItemGetter<T>();

    if (widget.response?.items == null) fetchData();
    // if (widget.paginate) {
    // _scrollController.addListener(() {
    //   final pos = _scrollController.position;
    //   if (pos.maxScrollExtent == pos.pixels) fetchData();
    // });
    // }

    PaginatedItemsBuilder.config ??=
        PaginatedItemsBuilderConfig.defaultConfig();

    super.initState();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    showLoader = (widget.paginate && (widget.response?.hasMoreData ?? false));
    itemsScrollController =
        widget.scrollController == null ? _scrollController : null;
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
    } else if (widget.shrinkWrap) {
      return _buildItems();
    } else {
      return RefreshIndicator(
        displacement: 10,
        onRefresh: () async => await fetchData(reset: true),
        child: _buildItems(),
      );
    }
  }

  Widget _buildItems() => widget.itemsDisplayType == ItemsDisplayType.list
      ? _buildListView()
      : _buildGridView();

  ListView _buildListView() {
    return ListView.separated(
      shrinkWrap: widget.shrinkWrap,
      physics: scrollPhysics,
      controller: itemsScrollController,
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
      controller: itemsScrollController,
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
