import 'package:easy_container/easy_container.dart';
import 'package:flutter/material.dart';
import 'package:paginated_items_builder_demo/models/post.dart';

class PostCard extends StatelessWidget {
  static const id = 'PostCard';

  final Post post;

  const PostCard(
    this.post, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return EasyContainer(
      alignment: Alignment.centerLeft,
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(post.body),
        ],
      ),
    );
  }
}
