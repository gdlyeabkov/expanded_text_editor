import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:texteditor/main.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  late DatabaseHandler handler;

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Открыть файл'),
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
      body: SingleChildScrollView(
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