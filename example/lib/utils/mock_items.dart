import 'package:paginated_items_builder/paginated_items_builder.dart';
import 'package:paginated_items_builder_demo/models/post.dart';

class MockItems {
  /// should return either an object of related type [T],
  /// or a widget.
  ///
  /// If an object is returned, then this item will be passed to the
  /// [PaginatedItemsBuilder.itemBuilder] with the context, index=0 and
  /// the item being this object.
  ///
  /// But if a widget is returned, then the widget is rendered directly.
  ///
  /// It is by default rendered inside an [IgnorePointer] to disable any onTap listeners.
  ///
  /// However, this can be changed by passing [PaginatedItemsBuilder.disableLoaderOnTaps] as false.
  static dynamic getByType<T>([String? mockItemKey]) {
    final key = mockItemKey ?? T.toString();
    switch (key) {
      case 'Post':
        return _post;
    }
  }

  static final _post = Post.fromJson({
    'id': 1,
    'userId': 1,
    'title': '■■■■■■■■',
    'body': '■■■■■■■■' * 10,
  });
}
