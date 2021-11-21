import 'dart:math';

import 'package:flutter/material.dart';
import 'package:paginated_items_builder/src/custom_loader.dart';
import 'package:paginated_items_builder/src/models/paginated_items_builder_config.dart';
import 'package:paginated_items_builder/src/models/paginated_items_response.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum ItemsDisplayType { list, grid }

class PaginatedItemsBuilder<T> extends StatefulWidget {
  const PaginatedItemsBuilder({
    Key? key,
    required this.fetchPageData,
    required this.response,
    required this.itemBuilder,
    this.itemsDisplayType = ItemsDisplayType.list,
    this.shrinkWrap = false,
    this.paginate = true,
    this.showResetIcon = true,
    this.neverScrollablePhysicsOnShrinkWrap = true,
    this.loader = const CustomLoader(),
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

  final Future<void> Function(bool) fetchPageData;
  final Widget Function(BuildContext, int, T) itemBuilder;
  final PaginatedItemsResponse<T>? response;
  final ScrollController? scrollController;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final EdgeInsets? padding;
  final bool neverScrollablePhysicsOnShrinkWrap;
  final String? emptyText;
  final bool showResetIcon;
  final bool paginate;
  final Widget? separatorWidget;
  final int? maxLength;
  final int loaderItemsCount;
  final ItemsDisplayType itemsDisplayType;
  final Widget loader;

  // config
  static PaginatedItemsBuilderConfig? config;

  // list
  final double? listItemsGap;

  // grid
  final int? gridCrossAxisCount;
  final double? gridMainAxisSpacing;
  final double? gridCrossAxisSpacing;
  final double? gridChildAspectRatio;

  @override
  _PaginatedItemsBuilderState<T> createState() => _PaginatedItemsBuilderState<T>();
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
    final mockItem = PaginatedItemsBuilder.config!.getByType<T>();

    Widget _buildLoader() => mockItem != null
        ? Shimmer.fromColors(
            highlightColor: PaginatedItemsBuilder.config!.shimmerConfig.highlightColor,
            baseColor: PaginatedItemsBuilder.config!.shimmerConfig.baseColor,
            period: PaginatedItemsBuilder.config!.shimmerConfig.period,
            child: IgnorePointer(
              child: widget.itemBuilder(context, 0, mockItem),
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
          if (widget.showResetIcon)
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

    if (widget.response?.items == null) fetchData();
    // if (widget.paginate) {
    // _scrollController.addListener(() {
    //   final pos = _scrollController.position;
    //   if (pos.maxScrollExtent == pos.pixels) fetchData();
    // });
    // }

    PaginatedItemsBuilder.config ??= PaginatedItemsBuilderConfig.defaultConfig();

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
