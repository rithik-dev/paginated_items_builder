import 'package:flutter/cupertino.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

/// Defines the type [ShowLoaderOnResetGetter].
typedef ShowLoaderOnResetGetter = bool Function(
  ItemsFetchScope itemsFetchScope,
);

/// Defines the type [RefreshIconBuilder].
typedef RefreshIconBuilder = Widget Function(VoidCallback refreshOnTap);

/// Defines the type [NoItemsTextGetter].
typedef NoItemsTextGetter = String Function(String name);

/// Defines the type [NoItemsWidgetBuilder].
typedef NoItemsWidgetBuilder = Widget Function(
  String? typeKey,
  VoidCallback refreshOnTap,
);

/// Defines the type [ErrorTextGetter].
typedef ErrorTextGetter = String Function(dynamic error);

/// Defines the type [ErrorWidgetBuilder].
typedef ErrorWidgetBuilder = Widget Function(
  dynamic error,
  VoidCallback refreshOnTap,
);
