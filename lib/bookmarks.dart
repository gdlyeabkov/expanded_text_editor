import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookmarksPage extends StatefulWidget {

  const BookmarksPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          title: Text('Открыть файл'),
        ),
        body: SingleChildScrollView(
        )
    );
  }

}