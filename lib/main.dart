import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:texteditor/recent_files.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'bookmarks.dart';
import 'db.dart';
import 'models.dart';
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
        '/file/open': (context) => OpenFilePage(title: 'title'),
        '/file/recent': (context) => RecentFilesPage(title: 'title'),
        '/bookmarks': (context) => BookmarksPage(title: 'title'),
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
  String mainTextAreaContent = '';
  int numLines = 1;
  bool isReadOnly = false;
  List<Widget> files = [];
  bool isFindDialogCase = false;
  bool isFindDialogRegex = false;
  bool isFindDialogCycle = true;
  int currentTab = 0;
  TimeStampType selectedTimeStamp = TimeStampType.one;
  Color pickerColor = Colors.black;
  StyleType selectedStyle = StyleType.Default;
  EncodingType selectedEncoding = EncodingType.utf16be;
  int tabsCount = 2;
  String savedFileName = '';
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

  addSavedFile(FileSystemEntity record, context) {
    String filePath = record.path;
    String fileName = basename(filePath);
    int fileSize = 0;
    File rawFile = File(filePath);
    bool isDir = new Directory(filePath).existsSync();
    bool isNotDir = !isDir;
    if (isNotDir) {
      fileSize = rawFile.lengthSync();
    }
    GestureDetector file = GestureDetector(
      child: Container(
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
      ),
      onTap: () {
        setState(() {
          savedFileName = fileName;
        });
      }
    );
    files.add(file);
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

  openInsertTimeStampDialog(context) {
    DateTime currentDate = DateTime.now();
    int currentDateDay = currentDate.day;
    int currentDateMonth = currentDate.month;
    int currentDateYear = currentDate.year;
    int currentDateHours = currentDate.hour;
    int currentDateMinutes = currentDate.minute;
    int currentDateSeconds = currentDate.second;
    String rawCurrentDateDay = currentDateDay.toString();
    String rawCurrentDateMonth = currentDateMonth.toString();
    String rawCurrentDateYear = currentDateYear.toString();
    String rawCurrentDateHours = currentDateHours.toString();
    String rawCurrentDateMinutes = currentDateMinutes.toString();
    String rawCurrentDateSeconds = currentDateSeconds.toString();
    bool isAddPrefix = false;
    int rawCurrentDateDayLength = rawCurrentDateDay.length;
    isAddPrefix = rawCurrentDateDayLength < 10;
    if (isAddPrefix) {
      rawCurrentDateDay = '0${rawCurrentDateDay}';
    }
    int rawCurrentDateMonthLength = rawCurrentDateMonth.length;
    isAddPrefix = rawCurrentDateMonthLength < 10;
    if (isAddPrefix) {
      rawCurrentDateMonth = '0${rawCurrentDateMonth}';
    }
    int rawCurrentDateHoursLength = rawCurrentDateHours.length;
    isAddPrefix = rawCurrentDateHoursLength < 10;
    if (isAddPrefix) {
      rawCurrentDateHours = '0${rawCurrentDateHours}';
    }
    int rawCurrentDateMinutesLength = rawCurrentDateMinutes.length;
    isAddPrefix = rawCurrentDateMinutesLength < 10;
    if (isAddPrefix) {
      rawCurrentDateMinutes = '0${rawCurrentDateMinutes}';
    }
    int rawCurrentDateSecondsLength = rawCurrentDateSeconds.length;
    isAddPrefix = rawCurrentDateSecondsLength < 10;
    if (isAddPrefix) {
      rawCurrentDateSeconds = '0${rawCurrentDateSeconds}';
    }
    String rawFirstTimeStamp = '';
    String rawSecondTimeStamp = '';
    String rawThirdTimeStamp = '';
    String rawFourTimeStamp = '';
    String rawFiveTimeStamp = '';
    String rawSixTimeStamp = '';
    String rawSevenTimeStamp = '';
    String rawEightTimeStamp = '';
    String rawNineTimeStamp = '';
    String rawTenTimeStamp = '';
    String rawElevenTimeStamp = '';
    String rawTwelthTimeStamp = '';
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Вставить временную метку'),
        content: Container(
          child: Column(
            children: [
              Row(
                children: [
                  Radio<TimeStampType>(
                    value: TimeStampType.one,
                    groupValue: selectedTimeStamp,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeStamp = value!;
                      });
                    }
                  ),
                  Text(
                    rawFirstTimeStamp
                  )
                ]
              ),
              Row(
                children: [
                  Radio<TimeStampType>(
                    value: TimeStampType.two,
                    groupValue: selectedTimeStamp,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeStamp = value!;
                      });
                    }
                  ),
                  Text(
                    rawSecondTimeStamp
                  )
                ]
              ),
              Row(
                children: [
                  Radio<TimeStampType>(
                    value: TimeStampType.three,
                    groupValue: selectedTimeStamp,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeStamp = value!;
                      });
                    }
                  ),
                  Text(
                    rawThirdTimeStamp
                  )
                ]
              ),
              Row(
                children: [
                  Radio<TimeStampType>(
                    value: TimeStampType.four,
                    groupValue: selectedTimeStamp,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeStamp = value!;
                      });
                    }
                  ),
                  Text(
                    rawFourTimeStamp
                  )
                ]
              ),
              Row(
                children: [
                  Radio<TimeStampType>(
                    value: TimeStampType.five,
                    groupValue: selectedTimeStamp,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeStamp = value!;
                      });
                    }
                  ),
                  Text(
                    rawFiveTimeStamp
                  )
                ]
              ),
              Row(
                children: [
                  Radio<TimeStampType>(
                    value: TimeStampType.six,
                    groupValue: selectedTimeStamp,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeStamp = value!;
                      });
                    }
                  ),
                  Text(
                    rawSixTimeStamp
                  )
                ]
              ),
              Row(
                children: [
                  Radio<TimeStampType>(
                    value: TimeStampType.seven,
                    groupValue: selectedTimeStamp,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeStamp = value!;
                      });
                    }
                  ),
                  Text(
                    rawSevenTimeStamp
                  )
                ]
              ),
              Row(
                children: [
                  Radio<TimeStampType>(
                    value: TimeStampType.eight,
                    groupValue: selectedTimeStamp,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeStamp = value!;
                      });
                    }
                  ),
                  Text(
                    rawEightTimeStamp
                  )
                ]
              ),
              Row(
                children: [
                  Radio<TimeStampType>(
                    value: TimeStampType.nine,
                    groupValue: selectedTimeStamp,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeStamp = value!;
                      });
                    }
                  ),
                  Text(
                    rawNineTimeStamp
                  )
                ]
              ),
              Row(
                children: [
                  Radio<TimeStampType>(
                    value: TimeStampType.ten,
                    groupValue: selectedTimeStamp,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeStamp = value!;
                      });
                    }
                  ),
                  Text(
                    rawTenTimeStamp
                  )
                ]
              ),
              Row(
                children: [
                  Radio<TimeStampType>(
                    value: TimeStampType.eleven,
                    groupValue: selectedTimeStamp,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeStamp = value!;
                      });
                    }
                  ),
                  Text(
                    rawElevenTimeStamp
                  )
                ]
              ),
              Row(
                children: [
                  Radio<TimeStampType>(
                    value: TimeStampType.twelth,
                    groupValue: selectedTimeStamp,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeStamp = value!;
                      });
                    }
                  ),
                  Text(
                    rawTwelthTimeStamp
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
            child: const Text('Отмена')
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

  openInsertColorDialog(context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Вставить цвет'),
        content: Container(
          child: Column(
            children: [
              ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (Color color) {
                  setState(() {
                    pickerColor = color;
                  });
                },
                pickerAreaBorderRadius: BorderRadius.circular(1000.0),
              )
            ]
          )
        ),
        actions: [
          TextButton(
            child: Text(
              'Отмена'
            ),
            onPressed: () {
              return Navigator.pop(context, 'Cancel');
            }
          ),
          TextButton(
            child: Text(
              'ОК'
            ),
            onPressed: () {
              print('${pickerColor.hashCode}');
              return Navigator.pop(context, 'OK');
            }
          ),
        ]
      )
    );
  }

  openEncodingDialog(context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Кодировка'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Radio<EncodingType>(
                    groupValue: selectedEncoding,
                    value: EncodingType.utf8,
                    onChanged: (value) {
                      setState(() {
                        selectedEncoding = value!;
                      });
                    }
                  ),
                  Text(
                    'UTF-8'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<EncodingType>(
                    groupValue: selectedEncoding,
                    value: EncodingType.utf16,
                    onChanged: (value) {
                      setState(() {
                        selectedEncoding = value!;
                      });
                    }
                  ),
                  Text(
                    'UTF-16'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<EncodingType>(
                    groupValue: selectedEncoding,
                    value: EncodingType.utf16be,
                    onChanged: (value) {
                      setState(() {
                        selectedEncoding = value!;
                      });
                    }
                  ),
                  Text(
                    'UTF-16 BE'
                  )
                ]
              )
            ]
          )
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              return Navigator.pop(context, 'Cancel');
            },
            child: const Text('Отмена')
          ),
          TextButton(
            onPressed: () {
              return Navigator.pop(context, 'OK');
            },
            child: const Text('OK')
          ),
        ]
      )
    );
  }

  openGoToStrokeDialog(context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Перейти к строке'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Введите номер строки (1 .. 5)'
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
              )
            ]
          )
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                return Navigator.pop(context, 'Cancel');
              },
              child: const Text('Отмена')
          ),
          TextButton(
              onPressed: () {
                return Navigator.pop(context, 'OK');
              },
              child: const Text('OK')
          ),
        ]
      )
    );
  }

  openStyleDialog(context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Стиль оформления'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.Default,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'По умолчанию'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.GitHub,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'GitHub'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.GitHubv2,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'GitHub v2'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.Tommorow,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'Tommorow'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.Hemisu,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'Hemisu'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.AtelierCave,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'Atelier Cave'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.AtelierDune,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'Atelier Dune'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.AtelierEstuary,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'Atelier Estuary'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.AtelierForest,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'Atelier Forest'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.AtelierHeath,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'Atelier Heath'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.AtelierLakeside,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'Atelier Lakeside'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.AtelierPlateau,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'Atelier Plateau'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.AtelierSavanna,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'Atelier Savanna'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.AtelierSeaside,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'Atelier Seaside'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<StyleType>(
                    groupValue: selectedStyle,
                    value: StyleType.AtelierSulphurpool,
                    onChanged: (value) {
                      setState(() {
                        selectedStyle = value!;
                      });
                    }
                  ),
                  Text(
                    'Atelier Sulphurpool'
                  )
                ]
              )
            ]
          )
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              return Navigator.pop(context, 'Cancel');
            },
            child: const Text('Отмена')
          ),
          TextButton(
            onPressed: () {
              return Navigator.pop(context, 'OK');
            },
            child: const Text('OK')
          )
        ]
      )
    );
  }

  openStatisticsDialog(context) {
    List<String> words = mainTextAreaContent.split(' ');
    int countWords = words.length;
    int countChars = mainTextAreaContent.length;
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Статистика'),
        content: Container(
          child: Column(
            children: [
              Text(
                'Количество слов'
              ),
              Text(
                '$countWords',
                style: TextStyle(
                  fontSize: 16
                )
              ),
              Text(
                'Количество символов'
              ),
              Text(
                '$countChars',
                style: TextStyle(
                  fontSize: 16
                )
              )
            ]
          )
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              return Navigator.pop(context, 'OK');
            },
            child: const Text('OK')
          )
        ]
      )
    );
  }

  getWidgetLines(List lines) {
    List<Widget> widgetLines = [];
    int linesCount = lines.length;
    double linesOffset = 1.5;
    for (int i = 0; i < linesCount; i++) {
      String lineNumber = '${i + 1}';
      widgetLines.add(
        Container(
          child: Text(
            lineNumber
          ),
          margin: EdgeInsets.symmetric(
            vertical: linesOffset
          )
        )
      );
    }
    return widgetLines;
  }

  Future<List> getLines() async {
    List lines = [];
    for (var i = 0; i < numLines; i++) {
      lines.add(i);
    }
    return lines;
  }

  openSaveDialog(context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Сохранить'),
        content: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'storage/emulated/0'
                ),
                Icon(
                  Icons.home
                )
              ]
            ),
            FutureBuilder(
              future: getFiles(),
              builder: (BuildContext context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
                int snapshotsCount = 0;
                if (snapshot.data != null) {
                  snapshotsCount = snapshot.data!.length;
                  files = [];
                  for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
                    addSavedFile(snapshot.data!.elementAt(snapshotIndex), context);
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
            Row(
              children: [
                Text(
                  'Имя файла'
                ),
                Text(
                  savedFileName
                )
              ]
            )
          ]
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              return Navigator.pop(context, 'Cancel');
            },
            child: const Text('Отмена')
          ),
          TextButton(
            onPressed: () {

              return Navigator.pop(context, 'OK');
            },
            child: const Text('Сохранить')
          ),
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
            setState(() {
              mainTextAreaContent = value;
              numLines = '\n'.allMatches(value).length + 1;
            });
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
      length: tabsCount,
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
                  openSaveDialog(context);
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
                if (menuItemName.content == 'Вставить') {

                } else if (menuItemName.content == 'Вставить цвет') {
                  openInsertColorDialog(context);
                } else if (menuItemName.content == 'Вставить временную метку') {
                  openInsertTimeStampDialog(context);
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
                } else if (menuItemName.content == 'Отправить') {

                } else if (menuItemName.content == 'Перейти к строке') {
                  openGoToStrokeDialog(context);
                } else if (menuItemName.content == 'Кодировка') {
                  openEncodingDialog(context);
                } else if (menuItemName.content == 'Стиль оформления') {
                  openStyleDialog(context);
                } else if (menuItemName.content == 'Статистика') {
                  openStatisticsDialog(context);
                } else if (menuItemName.content == 'Печать') {

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
                      Navigator.pushNamed(context, '/file/open');
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
                      openSaveDialog(context);
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
                          /*List.generate(numLines, (index) {
                            return Text(
                                '1'
                            );
                          })*/
                          /*ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              return Text(
                                '1'
                              );
                            },
                            itemCount: numLines
                          )*/
                          FutureBuilder(
                            future: getLines(),
                            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                              return Column(
                                children: getWidgetLines(snapshot.data!)
                              );
                            },
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