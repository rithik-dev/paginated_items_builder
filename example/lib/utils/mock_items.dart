import 'package:paginated_items_builder_demo/models/post.dart';

class MockItems {
  // ignore: body_might_complete_normally_nullable
  static dynamic getByType<T>([String? key]) {
    final typeKey = key ?? T.toString();
    switch (typeKey) {
      case 'Post':
        return _post as T;
    }
  }

  static final _post = Post.fromJson({
    'id': 1,
    'userId': 1,
    'title': '■■■■■■■■',
    'body': '■■■■■■■■■■■■■■■■',
  });
}
