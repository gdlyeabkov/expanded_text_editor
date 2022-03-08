import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

class DatabaseHandler {

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'flutter_text_editor.db'),
      onCreate: (database, version) async {
        await database.execute(
            "CREATE TABLE IF NOT EXISTS bookmarks(id INTEGER PRIMARY KEY, name TEXT, path TEXT)"
        );
      },
      version: 1,
    );
  }

  Future<int> insertBookmarks(List<Bookmark> bookmarks) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var bookmark in bookmarks){
      result = await db.insert('bookmarks', bookmark.toMap());
    }
    return result;
  }

  Future<int> addNewBookmarks(String name, String path) async {
    Bookmark firstBookmark = Bookmark(
      name: name,
      path: path
    );
    List<Bookmark> listOfBookmarks = [firstBookmark];
    return await insertBookmarks(listOfBookmarks);
  }

  Future<List<Bookmark>> retrieveBookmarks() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('bookmarks');
    var returnedBookmarks = queryResult.map((e) => Bookmark.fromMap(e)).toList();
    return returnedBookmarks;
  }

}