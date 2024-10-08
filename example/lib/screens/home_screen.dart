import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';
import 'package:paginated_items_builder_demo/controllers/posts_controller.dart';
import 'package:paginated_items_builder_demo/models/post.dart';
import 'package:paginated_items_builder_demo/repositories/posts_repository.dart';
import 'package:paginated_items_builder_demo/widgets/post_card.dart';

class HomeScreen extends StatelessWidget {
  static const id = 'HomeScreen';

  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const PostsListWithStateHandledExternally();
    // return const PostsListWithStateHandledInternally();
  }
}

//******************************************************************
// WITH CONTROLLER
//******************************************************************

class PostsListWithStateHandledExternally extends StatelessWidget {
  const PostsListWithStateHandledExternally({super.key});

  @override
  Widget build(BuildContext context) {
    final postsCon = PostsController.of(context);

    return SafeArea(
      child: Scaffold(
        body: PaginatedItemsBuilder<Post>(
          response: postsCon.postsResponse,
          // whether to turn all the existing cards into loaders or not.
          // If true, all the already displayed items will convert into
          // loaders, and then the new list will be rendered.

          // If false, then nothing will change on the screen while the data
          // is being fetched, when the data arrives, the content in the
          // cards will replace.
          showLoaderOnResetGetter: (itemsFetchScope) => [
            ItemsFetchScope.noItemsRefresh,
            ItemsFetchScope.onErrorRefresh,
            ItemsFetchScope.pullDownToRefresh,
          ].contains(itemsFetchScope),
          fetchPageData: (reset) => postsCon.updatePosts(reset: reset),
          itemBuilder: (context, idx, post) => PostCard(post),
          loaderItemsCount: 12,
        ),
      ),
    );
  }
}

//******************************************************************
// WITHOUT CONTROLLER
//******************************************************************

class PostsListWithStateHandledInternally extends StatelessWidget {
  const PostsListWithStateHandledInternally({super.key});

  /// function which calls the API and returns [PaginatedItemsResponse]
  Future<PaginatedItemsResponse<Post>> updatePosts(
    dynamic paginationKey,
  ) async {
    return await PostsRepository.getPosts(startKey: paginationKey);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PaginationItemsStateHandler<Post>(
          fetchPageData: updatePosts,
          builder: (response, fetchPageData) {
            return PaginatedItemsBuilder<Post>(
              response: response,
              fetchPageData: fetchPageData,
              itemBuilder: (context, _, post) => PostCard(post),
              loaderItemsCount: 12,
            );
          },
        ),
      ),
    );
  }
}
