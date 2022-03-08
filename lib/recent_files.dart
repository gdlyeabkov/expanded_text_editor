import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecentFilesPage extends StatefulWidget {

  const RecentFilesPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<RecentFilesPage> createState() => _RecentFilesPageState();
}

class _RecentFilesPageState extends State<RecentFilesPage> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text('Недавние файлы'),
      ),
      body: SingleChildScrollView(
      )
    );
  }

}