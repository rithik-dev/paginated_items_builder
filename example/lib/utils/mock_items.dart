import 'package:paginated_items_builder_demo/models/post.dart';

class MockItems {
  // ignore: body_might_complete_normally_nullable
  static T? getByType<T>() {
    switch (T.toString()) {
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
