import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class RecentFilesPage extends StatefulWidget {

  const RecentFilesPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<RecentFilesPage> createState() => _RecentFilesPageState();
}

class _RecentFilesPageState extends State<RecentFilesPage> {

  int currentTab = 0;
  List<Widget> files = [];

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<List<FileSystemEntity>> getFiles() async {
    String appDir = await _localPath;
    Directory dir = new Directory(appDir);
    Stream<FileSystemEntity> stream = dir.list();
    return stream.toList();
  }

  addFile(FileSystemEntity record, context) {
    String filePath = record.path;
    String fileName = basename(filePath);
    int fileSize = 0;
    File rawFile = File(filePath);
    bool isDir = new Directory(filePath).existsSync();
    bool isNotDir = !isDir;
    if (isNotDir) {
      fileSize = rawFile.lengthSync();
    }
    Container file = Container(
      height: 65,
      child: Row(
        children: [
          Icon(
            Icons.folder,
            size: 36
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${fileName}'
                ),
                Text(
                  '$fileSize'
                )
              ]
            ),
            margin: EdgeInsets.only(
                left: 15
            )
          )
        ]
      )
    );
    files.add(file);
  }

  @override
  Widget build(BuildContext context) {


    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child:  Scaffold(
        appBar: AppBar(
          title: Text('Недавние файлы'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                currentTab = index;
              });
            },
            tabs: <Widget>[
              Tab(
                text: 'Недавно открытые'
              ),
              Tab(
                text: 'Недавно добавленные'
              )
            ]
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            FutureBuilder(
              future: getFiles(),
              builder: (BuildContext context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
                int snapshotsCount = 0;
                if (snapshot.data != null) {
                  snapshotsCount = snapshot.data!.length;
                  files = [];
                  for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
                    var snapshotData = snapshot.data!;
                    FileSystemEntity snapshotDataItem = snapshotData.elementAt(snapshotIndex);
                    String filePath = snapshotDataItem.path;
                    File file = new File(filePath);
                    DateTime fileLastModified = file.lastModifiedSync();
                    DateTime currentDateTime = DateTime.now();
                    currentDateTime = currentDateTime.subtract(Duration(
                      days: 2
                    ));
                    bool isRecentOpened = fileLastModified.isAfter(currentDateTime);
                    if (isRecentOpened) {
                      addFile(snapshotDataItem, context);
                    }
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
                            children: files
                          )
                        )
                      )
                    ]
                  );
                } else {
                  return Column(

                  );
                }
                return Column(

                );
              }
            ),
            FutureBuilder(
              future: getFiles(),
              builder: (BuildContext context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
                int snapshotsCount = 0;
                if (snapshot.data != null) {
                  snapshotsCount = snapshot.data!.length;
                  files = [];
                  for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
                    var snapshotData = snapshot.data!;
                    FileSystemEntity snapshotDataItem = snapshotData.elementAt(snapshotIndex);
                    String filePath = snapshotDataItem.path;
                    File file = new File(filePath);
                    DateTime fileLastModified = file.lastModifiedSync();
                    DateTime currentDateTime = DateTime.now();
                    currentDateTime = currentDateTime.subtract(Duration(
                        days: 2
                    ));
                    bool isRecentAdded = fileLastModified.isAfter(currentDateTime);
                    if (isRecentAdded) {
                      addFile(snapshotDataItem, context);
                    }
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
                            children: files
                          )
                        )
                      )
                    ]
                  );
                } else {
                  return Column(

                  );
                }
                return Column(

                );
              }
            )
          ]
        )
      )
    );
  }

}