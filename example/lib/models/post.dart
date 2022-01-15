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
    final _json = <String, dynamic>{};
    _json['userId'] = userId;
    _json['id'] = id;
    _json['title'] = title;
    _json['body'] = body;
    return _json;
  }
}
