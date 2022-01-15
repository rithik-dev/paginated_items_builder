import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';
import 'package:paginated_items_builder_demo/controllers/posts_controller.dart';
import 'package:paginated_items_builder_demo/screens/home_screen.dart';
import 'package:paginated_items_builder_demo/utils/mock_items.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const _MainApp());
}

class _MainApp extends StatefulWidget {
  const _MainApp({Key? key}) : super(key: key);

  @override
  State<_MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<_MainApp> {
  @override
  void initState() {
    PaginatedItemsBuilder.config = PaginatedItemsBuilderConfig(
      mockItemGetter: MockItems.getByType,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PostsController(),
        ),
      ],
      child: const MaterialApp(
        title: 'PaginatedItemsBuilder Demo',
        home: HomeScreen(),
      ),
    );
  }
}
