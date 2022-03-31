import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

/// What if you have multiple [PaginatedItemsBuilder] widgets in a single view,
/// then every builder has it's own loader, and you want a pull down refresh
/// handler on the main page, and at the same time don't want every widget
/// to render it's own loader, instead, have a common global loader for the entire page.
///
/// Then you can use [LoaderShimmer], which is basically shimmer with the
/// [ShimmerConfig] properties as defaults, that can also be changed(if required)...
class LoaderShimmer extends StatelessWidget {
  static const id = 'LoaderShimmer';

  /// The shimmer's base color. Defaults to [ShimmerConfig.baseColor].
  final Color? baseColor;

  /// The shimmer's highlight color. Defaults to [ShimmerConfig.highlightColor].
  final Color? highlightColor;

  /// The shimmer's duration. Defaults to [ShimmerConfig.duration].
  final Duration? duration;

  /// The shimmer's direction. Defaults to [ShimmerConfig.direction].
  final ShimmerDirection? direction;

  /// Whether the shimmer is active or not.
  final bool isLoading;

  /// The child.
  final Widget child;

  const LoaderShimmer({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration,
    this.direction,
    this.isLoading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shimmerConfig = PaginatedItemsBuilder.config!.shimmerConfig;

    if (isLoading) {
      return Shimmer.fromColors(
        highlightColor: highlightColor ?? shimmerConfig.highlightColor,
        baseColor: baseColor ?? shimmerConfig.baseColor,
        period: duration ?? shimmerConfig.duration,
        direction: direction ?? shimmerConfig.direction,
        child: child,
      );
    } else {
      return child;
    }
  }
}
