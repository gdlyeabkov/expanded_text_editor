import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:texteditor/models.dart';

import 'db.dart';

class BookmarksPage extends StatefulWidget {

  const BookmarksPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {

  List<Widget> bookmarks = [];
  late DatabaseHandler handler;

  addBookmark(Bookmark record, context) {
    String bookmarkName = record.name;
    String bookmarkPath = record.path;
    Row bookmark = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          Icons.folder
        ),
        Column(
          children: [
            Text(
                bookmarkName
            ),
            Text(
              bookmarkPath
            )
          ]
        )
      ]
    );
    bookmarks.add(bookmark);
  }

  void initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          title: Text('Закладки'),
        ),
        body: FutureBuilder(
          future: handler.retrieveBookmarks(),
          builder: (BuildContext context, AsyncSnapshot<List<Bookmark>> snapshot) {
            int snapshotsCount = 0;
            if (snapshot.data != null) {
              snapshotsCount = snapshot.data!.length;
              bookmarks = [];
              for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
                addBookmark(snapshot.data!.elementAt(snapshotIndex), context);
              }
            }
            if (snapshot.hasData) {
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                        25
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: bookmarks
                      )
                    )
                  )
                ]
              );
            } else {
              return Center(
                child: Text(
                  'Закладок не найдено. Закладку можно\nсоздать из папок'
                )
              );
            }
            return Center(
              child: Text(
                'Закладок не найдено. Закладку можно\nсоздать из папок'
              )
            );
          }
        )
    );
  }

}