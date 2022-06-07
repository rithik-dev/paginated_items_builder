import 'package:flutter/material.dart' hide ErrorWidgetBuilder;
import 'package:paginated_items_builder/paginated_items_builder.dart';
import 'package:paginated_items_builder/src/config/config_defaults.dart';
import 'package:paginated_items_builder/src/type_definitions.dart';

/// The config for [PaginatedItemsBuilder].
class PaginatedItemsBuilderConfig {
  PaginatedItemsBuilderConfig({
    ShimmerConfig? shimmerConfig,
    this.mockItemGetter = ConfigDefaults.getByType,
    this.noItemsTextGetter = ConfigDefaults.noItemsTextGetter,
    this.errorTextGetter = ConfigDefaults.errorTextGetter,
    this.showLoaderOnResetGetter = ConfigDefaults.showLoaderOnResetGetter,
    this.noItemsTextStyle = ConfigDefaults.defaultTextStyle,
    this.errorTextStyle = ConfigDefaults.defaultTextStyle,
    this.loader = ConfigDefaults.defaultLoader,
    this.bottomLoader = ConfigDefaults.defaultLoader,
    this.logErrors = ConfigDefaults.logErrors,
    this.customScrollPhysics = ConfigDefaults.customScrollPhysics,
    this.padding = ConfigDefaults.padding,
  }) {
    this.shimmerConfig = shimmerConfig ?? ShimmerConfig();
  }

  /// Create a function and pass the reference to this.
  ///
  /// The function will be passed the type `T` and expects an object with mock
  /// data of type `T`. This calls the [PaginatedItemsBuilder]'s [itemBuilder]
  /// with the mockItem and overlays a shimmer for loading animation.
  ///
  /// You can also return a widget from this method, then that widget
  /// will be built in place of the loader.
  ///
  /// The widget is wrapped in an [IgnorePointer] when built to disable any
  /// onTap gesture listeners.
  ///
  /// However, this can be changed by passing
  /// [PaginatedItemsBuilder.disableLoaderOnTaps] as false,
  /// if you want to have loader onTap handlers...
  ///
  /// ```dart
  /// class MockItems {
  ///   static dynamic getByType<T>([String? mockItemKey]) {
  //     final key = mockItemKey ?? T.toString();
  //     switch (key) {
  //       case 'Post':
  //         return _post;
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

  /// {@macro noItemsTextGetter}
  late final NoItemsTextGetter noItemsTextGetter;

  /// {@macro noItemsWidgetBuilder}
  late final NoItemsWidgetBuilder noItemsWidgetBuilder;

  /// {@macro noItemsTextStyle}
  late final TextStyle noItemsTextStyle;

  /// {@macro errorTextGetter}
  late final ErrorTextGetter errorTextGetter;

  /// {@macro errorWidgetBuilder}
  late final ErrorWidgetBuilder errorWidgetBuilder;

  /// {@macro errorTextStyle}
  late final TextStyle errorTextStyle;

  /// {@macro loader}
  late final Widget loader;

  /// {@macro bottomLoader}
  late final Widget bottomLoader;

  /// {@macro showLoaderOnResetGetter}
  late final ShowLoaderOnResetGetter showLoaderOnResetGetter;

  /// {@macro logErrors}
  late final bool logErrors;

  /// {@macro customScrollPhysics}
  late final ScrollPhysics? customScrollPhysics;

  /// {@macro padding}
  late final EdgeInsets? padding;

  /// {@macro refreshIconBuilder}
  late final RefreshIconBuilder? refreshIconBuilder;
}

/// [ShimmerConfig] class to customize the loading shimmer colors, duration etc.
class ShimmerConfig {
  /// The shimmer's base color. Defaults to Colors.grey[300].
  final Color baseColor;

  /// The shimmer's highlight color. Defaults to Colors.grey[200].
  final Color highlightColor;

  /// The shimmer's duration. Defaults to 800ms.
  final Duration duration;

  /// The shimmer's direction. Defaults to [ShimmerDirection.ltr].
  final ShimmerDirection direction;

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
}
