import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:texteditor/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:path/path.dart';

import 'db.dart';
import 'models.dart';

class OpenFilePage extends StatefulWidget {
  const OpenFilePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<OpenFilePage> createState() => _OpenFilePageState();
}

class _OpenFilePageState extends State<OpenFilePage> {

  bool isFilterEnabled = false;
  var listContextMenuBtns = {
    SoftTrackRadioMenuItem(Icons.filter_none, 'Имя', FileSortType.name),
    SoftTrackRadioMenuItem(Icons.filter_none, 'Дата изменения', FileSortType.date)
  };
  FileSortType selectedFileSortType = FileSortType.name;
  String bookmarkName = '';
  String currentPath = '';
  String filesAction = '';
  List<Widget> files = [];
  late DatabaseHandler handler;

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

  openAddBookmarkDialog(context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Закладка'),
        content: Container(
          child: Column(
            children: [
              Text(
                'Имя'
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    bookmarkName = value;
                  });
                },
                decoration: new InputDecoration.collapsed(
                  hintText: '',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.0,
                      color: Colors.transparent,
                      style: BorderStyle.none
                    )
                  )
                )
              ),
              Text(
                'Путь'
              ),
              Text(
                'storage/emulated/0'
              ),
            ]
          )
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              return Navigator.pop(context, 'Cancel');
            },
            child: const Text('ОТМЕНА')
          ),
          TextButton(
            onPressed: () {
              handler.addNewBookmarks(bookmarkName, currentPath);
              return Navigator.pop(context, 'OK');
            },
            child: const Text('ОК')
          )
        ]
      )
    );
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
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() async {
        currentPath = await _localPath;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if (arguments != null) {
      print(arguments['filesAction']);
      filesAction = arguments['filesAction'];
    }
    final List<UnicornButton> floatingButtons = [];
    if (filesAction == 'Сохранить как') {
      floatingButtons.add(
        UnicornButton(
          hasLabel: true,
          labelText: 'Сохранить как',
          labelBackgroundColor: Color.fromARGB(255, 100, 100, 100),
          labelColor: Colors.white,
          currentButton: FloatingActionButton(
            heroTag: 'Сохранить как',
            backgroundColor: Color.fromARGB(255, 0, 185, 0),
            mini: true,
            child: Icon(Icons.save),
            onPressed: () {
              print('Сохранить как');
            },
          ),
        ),
      );
    } else {
      floatingButtons.add(
        UnicornButton(
          hasLabel: true,
          labelText: 'Создать файл',
          labelBackgroundColor: Color.fromARGB(255, 100, 100, 100),
          labelColor: Colors.white,
          currentButton: FloatingActionButton(
            heroTag: 'Создать файл',
            backgroundColor: Color.fromARGB(255, 0, 185, 0),
            mini: true,
            child: Icon(Icons.insert_drive_file_outlined),
            onPressed: () {
              print('Создать файл');
            },
          ),
        ),
      );
    }

    floatingButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "Создать папку",
        labelBackgroundColor: Color.fromARGB(255, 100, 100, 100),
        labelColor: Colors.white,
        currentButton: FloatingActionButton(
          heroTag: "Создать папку",
          backgroundColor: Color.fromARGB(255, 0, 185, 0),
          mini: true,
          child: Icon(Icons.folder_open),
          onPressed: () {
            print('Создать папку');
          },
        ),
      )
    );

    return Scaffold(
      floatingActionButton: UnicornDialer(
        backgroundColor: Colors.transparent,
        parentButtonBackground: Color.fromARGB(255, 0, 185, 0),
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(Icons.add),
        childButtons: floatingButtons
      ),
      appBar: AppBar(
        title: Text(filesAction),
        actions: [
          PopupMenuButton<SoftTrackRadioMenuItem>(
            itemBuilder: (BuildContext context) {
              return listContextMenuBtns.map((SoftTrackRadioMenuItem choice) {
                return PopupMenuItem<SoftTrackRadioMenuItem>(
                  value: choice,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          left: 15
                        ),
                        child: Text(
                          choice.content
                        )
                      ),
                      Radio<FileSortType>(
                        value: choice.value,
                        groupValue: selectedFileSortType,
                        onChanged: (value) {
                          setState(() {
                            selectedFileSortType = selectedFileSortType == FileSortType.name ? FileSortType.date : FileSortType.name;
                          });
                        }
                      )
                    ]
                  )
                );
              }).toList();
            },
            onSelected: (menuItemName) {

            },
            child: Icon(
              Icons.list
            )
          ),
          FlatButton(
            child: Icon(
              Icons.star_outline
            ),
            onPressed: () {
              openAddBookmarkDialog(context);
            }
          ),
          FlatButton(
            child: Icon(
              (
                isFilterEnabled ?
                  Icons.filter_alt
                :
                  Icons.filter_alt_outlined
              )
            ),
            onPressed: () {
              String notificationMsg = '';
              setState(() {
                isFilterEnabled = !isFilterEnabled;
                if (isFilterEnabled) {
                  notificationMsg = 'Фильтр файлов ВКЛ';
                } else {
                  notificationMsg = 'Фильтр файлов ОТКЛ';
                }
                Fluttertoast.showToast(
                  msg: notificationMsg,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0
                );
              });
            }
          )
        ]
      ),
      body: FutureBuilder(
        future: getFiles(),
        builder: (BuildContext context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
          int snapshotsCount = 0;
          if (snapshot.data != null) {
            snapshotsCount = snapshot.data!.length;
            files = [];
            for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
              addFile(snapshot.data!.elementAt(snapshotIndex), context);
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
    );
  }

}

class SoftTrackRadioMenuItem extends SoftTrackMenuItem {

  FileSortType value = FileSortType.name;

  SoftTrackRadioMenuItem(icon, content, value) : super(icon, content) {
    this.value = value;
  }
}