import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

/// Default loader used for items used by the [PaginatedItemsBuilder] if no mockItem
/// exists in the [PaginatedItemsBuilderConfig]'s [mockItemGetter] variable.
class CustomLoader extends StatelessWidget {
  final Color? color;
  final double radius;
  final double padding;

  const CustomLoader({
    Key? key,
    this.color,
    this.radius = 15,
    this.padding = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Platform.isIOS
            ? CupertinoActivityIndicator(radius: radius)
            : SizedBox(
                height: radius * 2,
                width: radius * 2,
                child: CircularProgressIndicator(
                  color: color ?? Theme.of(context).colorScheme.secondary,
                ),
              ),
      ),
    );
  }
}
