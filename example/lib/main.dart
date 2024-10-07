import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';
import 'package:paginated_items_builder_demo/controllers/posts_controller.dart';
import 'package:paginated_items_builder_demo/screens/home_screen.dart';
import 'package:paginated_items_builder_demo/utils/mock_items.dart';
import 'package:provider/provider.dart';

void main() => runApp(const _MainApp());

class _MainApp extends StatelessWidget {
  const _MainApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PostsController>(
          create: (_) => PostsController(),
        ),
      ],
      child: MaterialApp(
        title: 'PaginatedItemsBuilder Demo',
        builder: (context, child) {
          late final Color shimmerBaseColor;
          late final Color shimmerHighlightColor;

          switch (Theme.of(context).brightness) {
            case Brightness.light:
              shimmerBaseColor = Colors.grey[300]!;
              shimmerHighlightColor = Colors.grey[100]!;
              break;
            case Brightness.dark:
              shimmerBaseColor = const Color(0xFF031956);
              shimmerHighlightColor = const Color(0x80031956);
              break;
          }

          PaginatedItemsBuilder.config = PaginatedItemsBuilderConfig(
            mockItemGetter: MockItems.getByType,
            shimmerConfig: ShimmerConfig(
              baseColor: shimmerBaseColor,
              highlightColor: shimmerHighlightColor,
              duration: const Duration(seconds: 1),
            ),
          );

          return child!;
        },
        home: const HomeScreen(),
      ),
    );
  }
}
