import 'package:flutter/material.dart';

class PaginatedItemsBuilderConfig {
  PaginatedItemsBuilderConfig({
    required this.shimmerConfig,
    required this.getByType,
    required this.noItemsTextGetter,
    required this.noItemsTextStyle,
  });

  PaginatedItemsBuilderConfig.defaultConfig() {
    shimmerConfig = ShimmerConfig.defaultShimmer();
    getByType = <T>() {};
    noItemsTextGetter = (name) => "No ${name}s found!";
    noItemsTextStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
  }

  late final T? Function<T>() getByType;
  late final ShimmerConfig shimmerConfig;
  late final String Function(String name) noItemsTextGetter;
  late final TextStyle noItemsTextStyle;
}

class ShimmerConfig {
  late final Color baseColor;
  late final Color highlightColor;
  late final Duration period;

  ShimmerConfig({
    required this.baseColor,
    required this.highlightColor,
    required this.period,
  });

  ShimmerConfig.defaultShimmer() {
    baseColor = Colors.grey[300]!;
    highlightColor = Colors.grey[200]!;
    period = const Duration(milliseconds: 175);
  }
}
