import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

/// ConfigDefaults
class ConfigDefaults {
  /// getByType
  static dynamic getByType<T>([String? mockItemKey]) => null;

  /// noItemsTextGetter
  static String noItemsTextGetter(String name) {
    final beforeCapitalLetter = RegExp(r"(?=[A-Z])");
    name = name
        .split(beforeCapitalLetter)
        .map(
          (e) => e.toLowerCase(),
        )
        .join(' ');

    return "No ${name}s found!";
  }

  /// errorTextGetter
  static String errorTextGetter(dynamic error) => 'Something went wrong!';

  /// showLoaderOnResetGetter
  static bool showLoaderOnResetGetter(scope) =>
      scope != ItemsFetchScope.pullDownToRefresh;

  /// defaultTextStyle
  static const defaultTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  /// defaultLoader
  static const defaultLoader = Center(
    child: CircularProgressIndicator.adaptive(),
  );

  /// logErrors
  static const logErrors = true;

  /// customScrollPhysics
  static const customScrollPhysics = null;

  /// padding
  static const padding = null;
}
