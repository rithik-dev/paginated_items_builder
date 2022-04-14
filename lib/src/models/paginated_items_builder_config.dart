import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

dynamic _getByType<T>([String? key]) => null;

String _noItemsTextGetter(String name) {
  final beforeCapitalLetter = RegExp(r"(?=[A-Z])");
  name = name.split(beforeCapitalLetter).map((e) => e.toLowerCase()).join(' ');
  return "No ${name}s found!";
}

/// The config for [PaginatedItemsBuilder].
class PaginatedItemsBuilderConfig {
  PaginatedItemsBuilderConfig({
    ShimmerConfig? shimmerConfig,
    dynamic Function<T>([String? key])? mockItemGetter,
    String Function(String name)? noItemsTextGetter,
    this.noItemsTextStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
    this.logErrors = true,
  })  : shimmerConfig = shimmerConfig ?? ShimmerConfig.defaultShimmer(),
        mockItemGetter = mockItemGetter ?? _getByType,
        noItemsTextGetter = noItemsTextGetter ?? _noItemsTextGetter;

  /// Default config
  PaginatedItemsBuilderConfig.defaultConfig() {
    shimmerConfig = ShimmerConfig.defaultShimmer();
    mockItemGetter = _getByType;
    noItemsTextGetter = _noItemsTextGetter;
    noItemsTextStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
    logErrors = true;
  }

  /// Create a function and pass the reference to this.
  ///
  /// The function will be passed the type `T` and expects an object with mock
  /// data of type `T`. This calls the [PaginatedItemsBuilder]'s [itemBuilder]
  /// with the mockItem and overlays a shimmer for loading animation.
  ///
  /// ```dart
  /// class MockItems {
  ///   static dynamic getMockItemByType<T>([String? key]) {
  //     final typeKey = key ?? T.toString();
  //     switch (typeKey) {
  //       case 'Post':
  //         return _post as T;
  //     }
  //   }
  ///
  ///   static final _post = Post();
  ///   ```
  /// }
  late final dynamic Function<T>([String? key]) mockItemGetter;

  /// Provide a [ShimmerConfig] to customize the shimmer loading animation
  /// color, or the duration.
  late final ShimmerConfig shimmerConfig;

  /// Customize the text that is rendered when there are no items to display.
  late final String Function(String name) noItemsTextGetter;

  /// Customize the style of the text that is rendered when there
  /// are no items to display.
  late final TextStyle noItemsTextStyle;

  /// Whether to log errors to the console or not.
  late final bool logErrors;
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
