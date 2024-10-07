class Post {
  late final int userId;
  late final int id;
  late final String title;
  late final String body;

  Post.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    id = json['id'];
    title = json['title'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['userId'] = userId;
    json['id'] = id;
    json['title'] = title;
    json['body'] = body;
    return json;
  }
}
