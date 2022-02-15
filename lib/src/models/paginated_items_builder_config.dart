import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

/// The config for [PaginatedItemsBuilder].
class PaginatedItemsBuilderConfig {
  PaginatedItemsBuilderConfig({
    ShimmerConfig? shimmerConfig,
    T? Function<T>()? mockItemGetter,
    String Function(String name)? noItemsTextGetter,
    this.noItemsTextStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
  })  : shimmerConfig = shimmerConfig ?? ShimmerConfig.defaultShimmer(),
        mockItemGetter = mockItemGetter ?? (<T>() => null),
        noItemsTextGetter =
            noItemsTextGetter ?? ((name) => "No ${name}s found!");

  /// Default config
  PaginatedItemsBuilderConfig.defaultConfig() {
    shimmerConfig = ShimmerConfig.defaultShimmer();
    mockItemGetter = <T>() => null;
    noItemsTextGetter = (name) => "No ${name}s found!";
    noItemsTextStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
  }

  /// Create a function and pass the reference to this.
  ///
  /// The function will be passed the type `T` and expects an object with mock
  /// data of type `T`. This calls the [PaginatedItemsBuilder]'s [itemBuilder]
  /// with the mockItem and overlays a shimmer for loading animation.
  ///
  /// class MockItems {
  ///   static T? getMockItemByType<T>() {
  ///     switch (T.toString()) {
  ///       case 'Product':
  ///         return _product as T?;
  ///     }
  ///   }
  ///
  ///   static final _product = Product();
  /// }
  late final T? Function<T>() mockItemGetter;

  /// Provide a [ShimmerConfig] to customize the shimmer loading animation
  /// color, or the duration.
  late final ShimmerConfig shimmerConfig;

  /// Customize the text that is rendered when there are no items to display.
  late final String Function(String name) noItemsTextGetter;

  /// Customize the style of the text that is rendered when there
  /// are no items to display.
  late final TextStyle noItemsTextStyle;
}

/// [ShimmerConfig] class to customize the loading shimmer colors, duration etc.
class ShimmerConfig {
  /// The shimmer's base color. Defaults to Colors.grey[300].
  late final Color baseColor;

  /// The shimmer's highlight color. Defaults to Colors.grey[200].
  late final Color highlightColor;

  /// The shimmer's duration. Defaults to 800ms.
  late final Duration duration;

  /// The shimmer's direction. Defaults to [ShimmerDirection.ltr].
  late final ShimmerDirection direction;

  static final _defaultBaseColor = Colors.grey[300]!;
  static final _defaultHighlightColor = Colors.grey[200]!;
  static const _defaultDirection = ShimmerDirection.ltr;
  static const _defaultDuration = Duration(milliseconds: 800);

  ShimmerConfig({
    Color? baseColor,
    Color? highlightColor,
    this.direction = _defaultDirection,
    this.duration = _defaultDuration,
  })  : baseColor = baseColor ?? _defaultBaseColor,
        highlightColor = highlightColor ?? _defaultHighlightColor;

  /// default
  ShimmerConfig.defaultShimmer() {
    baseColor = _defaultBaseColor;
    highlightColor = _defaultHighlightColor;
    direction = _defaultDirection;
    duration = _defaultDuration;
  }
}
