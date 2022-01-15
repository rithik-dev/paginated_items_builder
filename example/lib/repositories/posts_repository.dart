import 'package:dio/dio.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';
import 'package:paginated_items_builder_demo/models/post.dart';

class PostsRepository {
  const PostsRepository._();

  static Future<PaginatedItemsResponse<Post>?> getPosts({
    String? startKey,
  }) async {
    // use dio or http to call api and get the response. and pass the contents
    // in the constructor for [PaginatedItemsResponse].

    // Don't forget to pass the idGetter parameter here.

    final res = await Dio().get('https://jsonplaceholder.typicode.com/posts');
    return PaginatedItemsResponse<Post>(
      listItems: res.data?.map((e) => Post.fromJson(e)).cast<Post>(),
      // no support for pagination for current api
      paginationKey: null,
      idGetter: (post) => post.id.toString(),
    );
  }
}
