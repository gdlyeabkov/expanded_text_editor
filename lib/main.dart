import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import 'db.dart';
import 'open_file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Softtrack Текстовый редактор',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Softtrack Текстовый редактор'),
      routes: {
        '/main': (context) => MyHomePage(title: 'title'),
        '/file/open': (context) => OpenFilePage(title: 'title')
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var folderContextMenuBtns = {
    SoftTrackMenuItem(Icons.add, 'Создать'),
    SoftTrackMenuItem(Icons.folder_open, 'Открыть'),
    SoftTrackMenuItem(Icons.folder_open, 'Открыть (SAF)'),
    SoftTrackMenuItem(Icons.save, 'Сохранить'),
    SoftTrackMenuItem(Icons.save_as, 'Сохранить как'),
    SoftTrackMenuItem(Icons.refresh, 'Перезагрузить'),
    SoftTrackMenuItem(Icons.close, 'Закрыть')
  };
  var penContextMenuBtns = {
    SoftTrackMenuItem(Icons.undo, 'Отменить'),
    SoftTrackMenuItem(Icons.redo, 'Повторить'),
    SoftTrackMenuItem(Icons.select_all, 'Вылелить все'),
    SoftTrackMenuItem(Icons.paste, 'Вставить'),
    SoftTrackMenuItem(Icons.brush, 'Вставить цвет'),
    SoftTrackMenuItem(Icons.access_time_outlined, 'Вставить временную метку'),
    SoftTrackMenuItem(Icons.arrow_forward, 'Увеличить отступ'),
    SoftTrackMenuItem(Icons.arrow_back, 'Уменьшить отступ'),
  };
  var moreContextMenuBtns = {
    SoftTrackCheckableMenuItem(Icons.search, 'Найти', null),
    SoftTrackCheckableMenuItem(Icons.share, 'Отправить', null),
    SoftTrackCheckableMenuItem(Icons.double_arrow_outlined, 'Перейти к строке', null),
    SoftTrackCheckableMenuItem(Icons.fence, 'Кодировка', null),
    SoftTrackCheckableMenuItem(Icons.photo, 'Стиль оформления', null),
    SoftTrackCheckableMenuItem(Icons.bar_chart, 'Статистика', null),
    SoftTrackCheckableMenuItem(Icons.print, 'Печать', null),
    SoftTrackCheckableMenuItem(Icons.touch_app, 'Панель инстр...', true),
    SoftTrackCheckableMenuItem(Icons.wrap_text, 'Переносить слова', false),
    SoftTrackCheckableMenuItem(Icons.lock, 'Только чтение', false)
  };
  bool isSelectionMode = false;
  TextField mainTextArea = TextField();
  bool isReadOnly = false;
  List<Widget> files = [];
  bool isFindDialogCase = false;
  bool isFindDialogRegex = false;
  bool isFindDialogCycle = true;
  int currentTab = 0;
  late DatabaseHandler handler;

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  bool getEnabled() {
    return !isReadOnly;
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
      width: 200,
      child: Row(
        children: [
          Icon(
            Icons.folder,
            size: 36
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${fileName}'
              ),
              Text(
                '$fileSize'
              )
            ]
          )
        ]
      )
    );
    files.add(file);
  }

  createFile() async {
     // String appDir = (await getApplicationDocumentsDirectory()).path;
     String appDir = await _localPath;
     String filePath = '${appDir}/flutter_text_plain_2.txt';
     var myFile = new File(filePath);
     myFile.createSync();
     myFile.writeAsString("abc");
  }

  openFindDialog(context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Найти'),
        content: Container(
          child: Column(
            children: [
              Text(
                'Найти'
              ),
              TextField(
                onChanged: (value) {

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
                'Заменить на'
              ),
              TextField(
                onChanged: (value) {

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
              Row(
                children: [
                  Checkbox(
                    value: isFindDialogCase,
                    onChanged: (value) {
                      setState(() {
                        isFindDialogCase = !isFindDialogCase;
                      });
                    }
                  ),
                  Text(
                    'Учитывать регистр'
                  )
                ]
              ),
              Row(
                children: [
                  Checkbox(
                    value: isFindDialogRegex,
                    onChanged: (value) {
                      setState(() {
                        isFindDialogRegex = !isFindDialogRegex;
                      });
                    }
                  ),
                  Text(
                    'Регулярное выражение'
                  )
                ]
              ),
              Row(
                children: [
                  Checkbox(
                    value: isFindDialogCycle,
                    onChanged: (value) {
                      setState(() {
                        isFindDialogCycle = !isFindDialogCycle;
                      });
                    }
                  ),
                  Text(
                    'Зациклить поиск'
                  )
                ]
              )
            ]
          )
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {

            },
            child: const Text('Заменить')
          ),
          TextButton(
            onPressed: () {

            },
            child: const Text('Заменить все')
          ),
          TextButton(
            onPressed: () {

            },
            child: const Text('Готово')
          )
        ]
      )
    );
  }

  @override
  void initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {
        mainTextArea = TextField(
          onChanged: (value) {

          },
          readOnly: isReadOnly,
          // enabled: getEnabled(),
          decoration: new InputDecoration.collapsed(
            hintText: '',
            border: OutlineInputBorder(
              borderSide: BorderSide(
                width: 0.0,
                color: Colors.transparent,
                style: BorderStyle.none
              )
            )
          ),
          maxLines: null
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            PopupMenuButton<SoftTrackMenuItem>(
              itemBuilder: (BuildContext context) {
                return folderContextMenuBtns.map((SoftTrackMenuItem choice) {
                  return PopupMenuItem<SoftTrackMenuItem>(
                    value: choice,
                    child: Row(
                      children: [
                        Icon(
                          choice.icon,
                          color: Colors.black
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                          child: Text(
                            choice.content
                          )
                        )
                      ]
                    )
                  );
                }).toList();
              },
              onSelected: (menuItemName) {
                if (menuItemName.content == 'Создать') {
                  createFile();
                } else if (menuItemName.content == 'Открыть') {
                  Navigator.pushNamed(context, '/file/open');
                } else if (menuItemName.content == 'Открыть (SAF)') {
                  Navigator.pushNamed(context, '/file/open');
                } else if (menuItemName.content == 'Сохранить') {
                  openFindDialog(context);
                } else if (menuItemName.content == 'Сохранить как') {
                  Navigator.pushNamed(context, '/file/open');
                } else if (menuItemName.content == 'Перезагрузить') {
                  SystemNavigator.pop();
                  exit(0);
                } else if (menuItemName.content == 'Закрыть') {
                  SystemNavigator.pop();
                  exit(0);
                }
              },
              child: Icon(
                Icons.folder
              )
            ),
            PopupMenuButton<SoftTrackMenuItem>(
              itemBuilder: (BuildContext context) {
                return penContextMenuBtns.map((SoftTrackMenuItem choice) {
                  return PopupMenuItem<SoftTrackMenuItem>(
                    value: choice,
                    child: Row(
                      children: [
                        Icon(
                          choice.icon,
                          color: Colors.black
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                          child: Text(
                            choice.content
                          )
                        )
                      ]
                    )
                  );
                }).toList();
              },
              onSelected: (menuItemName) {
                if (menuItemName == 'Управление элементами') {

                }
              },
              child: Container(
                margin: EdgeInsets.only(
                  left: 20
                ),
                child: Icon(
                  Icons.brush
                )
              )
            ),
            PopupMenuButton<SoftTrackCheckableMenuItem>(
              itemBuilder: (BuildContext context) {
                int moreContextMenuBtnsIndex = -1;
                return moreContextMenuBtns.map((SoftTrackCheckableMenuItem choice) {
                  moreContextMenuBtnsIndex++;
                  return PopupMenuItem<SoftTrackCheckableMenuItem>(
                    value: choice,
                    child: Row(
                      children: [
                        Row(
                          children: [

                            Icon(
                              choice.icon,
                              color: Colors.black
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: 15
                              ),
                              child: Text(
                                choice.content
                              )
                            )
                          ]
                        ),
                        (
                          choice.checked != null ?
                            Checkbox(
                              value: choice.checked,
                              onChanged: (value) {
                                setState(() {
                                  moreContextMenuBtns.elementAt(moreContextMenuBtnsIndex).checked = !moreContextMenuBtns.elementAt(moreContextMenuBtnsIndex).checked!;
                                  // choice.checked = value;
                                });
                              }
                            )
                          :
                            Text('')
                        )
                      ]
                    )
                  );
                }).toList();
              },
              onSelected: (menuItemName) {
                if (menuItemName.content == 'Найти') {
                  openFindDialog(context);
                } else if (menuItemName.content == 'Только чтение') {
                  setState(() {
                    isReadOnly = !isReadOnly;
                    // isReadOnly = false;
                  });
                }
              }
            )
          ],
          bottom: TabBar(
            onTap: (index) {
              print('currentTabIndex: ${index}');
              setState(() {
                currentTab = index;
              });
            },
            tabs: <Widget>[
              Tab(
                text: 'Безымянный.txt'
              ),
              Tab(
                text: 'Database Inspector'
              )
            ]
          )
        ),
        persistentFooterButtons: [
          (
            moreContextMenuBtns.elementAt(7).checked! ?
              Row(
                children: [
                  TextButton(
                    child: Icon(
                      Icons.folder
                    ),
                    onPressed: () {

                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    )
                  ),
                  TextButton(
                    child: Icon(
                      Icons.undo
                    ),
                    onPressed: () {

                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    )
                  ),
                  TextButton(
                    child: Icon(
                      Icons.redo
                    ),
                    onPressed: () {

                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    )
                  ),
                  TextButton(
                    child: Icon(
                      Icons.search
                    ),
                    onPressed: () {
                      openFindDialog(context);
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    )
                  ),
                  TextButton(
                    child: Icon(
                      Icons.save
                    ),
                    onPressed: () {

                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    )
                  ),
                  TextButton(
                    child: Icon(
                      Icons.close
                    ),
                    onPressed: () {

                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    )
                  )
                ]
              )
            :
              Text(
                ''
              )
          )
        ],
        body: TabBarView(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                child: Row(
                  children: [
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '1'
                          )
                        ]
                      ),
                      width: 25,
                      height: MediaQuery.of(context).size.height - 165,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height - 165,
                      width: MediaQuery.of(context).size.width - 25,
                      child: mainTextArea
                    )
                  ]
                )
              )
            ),
            TextButton(
              child: Text(
                'Database Inspector'
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => DatabaseList()));
              }
            )
          ]
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 150
              ),
              Column(
                children: [
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone_android
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                          child: Text(
                            'Внутренняя память'
                          )
                        )
                      ]
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/file/open');
                    }
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_outline
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                          child: Text(
                            'Закладки'
                          )
                        )
                      ]
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/bookmarks');
                    }
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                          child: Text(
                            'Недавние файлы'
                          )
                        )
                      ]
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/file/recent');
                    }
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_download_outlined
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                          child: Text(
                            'Диспетчер памяти'
                          )
                        )
                      ]
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/file/open');
                    }
                  )
                ]
              ),
              Divider(
                thickness: 1.0
              ),
              Column(
                children: [
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_arrow_sharp
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                          child: Text(
                            'Убрать рекламу'
                          )
                        )
                      ]
                    ),
                    onPressed: () {
                      // Убрать рекламу
                    }
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.mail_outline
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                          child: Text(
                            'Рекомендовать'
                          )
                        )
                      ]
                    ),
                    onPressed: () {
                      // Рекомендовать
                    }
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                          child: Text(
                            'Настройки'
                          )
                        )
                      ]
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    }
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.help_outline
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                          child: Text(
                            'Справка'
                          )
                        )
                      ]
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/help');
                    }
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      )
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.exit_to_app
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                          child: Text(
                            'Выход'
                          )
                        )
                      ]
                    ),
                    onPressed: () {
                      // Закрыть приложение
                    }
                  )
                ]
              )
            ]
          )
        ),// This trailing
        endDrawer: Drawer(
          child: FutureBuilder(
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
        )
      )// This trailing// comma makes auto-formatting nicer for build methods.
    );
  }
}

class SoftTrackMenuItem {
  late IconData icon;
  late String content;

  SoftTrackMenuItem(icon, content) {
    this.icon = icon;
    this.content = content;
  }

}

class SoftTrackCheckableMenuItem extends SoftTrackMenuItem {
  
  late bool? checked;

  SoftTrackCheckableMenuItem(icon, content, checked) : super(icon, content) {
    this.checked = checked;
  }

}