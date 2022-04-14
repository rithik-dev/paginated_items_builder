import 'package:flutter/cupertino.dart' show BuildContext, ChangeNotifier;
import 'package:paginated_items_builder/paginated_items_builder.dart';
import 'package:paginated_items_builder_demo/models/post.dart';
import 'package:paginated_items_builder_demo/repositories/posts_repository.dart';
import 'package:provider/provider.dart';

class PostsController extends ChangeNotifier {
  // not necessary, just something I use, which makes the code better.
  static PostsController of(
    BuildContext context, {
    bool listen = true,
  }) =>
      Provider.of<PostsController>(context, listen: listen);

  PaginatedItemsResponse<Post>? _postsResponse;

  PaginatedItemsResponse<Post>? get postsResponse => _postsResponse;

  Future<PaginatedItemsResponse<Post>?> updatePosts({
    bool reset = false,
  }) async {
    final res = await PostsRepository.getPosts(
      startKey: reset ? null : _postsResponse?.paginationKey,
    );
    if (reset || _postsResponse == null) {
      _postsResponse = res;
    } else {
      _postsResponse?.update(res);
    }
    notifyListeners();
    return _postsResponse;
  }

  void clear() {
    _postsResponse = null;
    notifyListeners();
  }
}
