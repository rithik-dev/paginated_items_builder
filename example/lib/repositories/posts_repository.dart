import 'package:dio/dio.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';
import 'package:paginated_items_builder_demo/models/post.dart';

class PostsRepository {
  const PostsRepository._();

  static Future<PaginatedItemsResponse<Post>> getPosts({
    dynamic startKey,
  }) async {
    // call api and get the response, and pass the contents
    // in the constructor for [PaginatedItemsResponse].

    final res = await Dio().get('https://jsonplaceholder.typicode.com/posts');
    return PaginatedItemsResponse<Post>.fromListWithNoPaginationSupport(
      data: res.data.map((e) => Post.fromJson(e)).cast<Post>().toList(),
      idGetter: (post) => post.id.toString(),
    );
  }
}
