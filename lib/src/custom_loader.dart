import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  static const id = 'CustomLoader';

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
