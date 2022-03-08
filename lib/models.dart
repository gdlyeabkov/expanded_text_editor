class Bookmark {
  final int? id;
  final String name;
  final String path;

  Bookmark({
    this.id,
    required this.name,
    required this.path
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path
    };
  }

  Bookmark.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        name = res["name"],
        path = res["path"];

}

enum FileSortType {
  name,
  date
}