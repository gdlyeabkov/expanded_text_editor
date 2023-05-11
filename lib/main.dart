import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intent/category.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:texteditor/recent_files.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:clipboard/clipboard.dart';
import 'package:intl/intl.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:texteditor/settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:intent/action.dart' as android_action;

import 'bookmarks.dart';
import 'db.dart';
import 'help.dart';
import 'memory_manager.dart';
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
      title: 'Текстовый редактор',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Текстовый редактор'),
      routes: {
        '/main': (context) => MyHomePage(title: 'title'),
        '/file/open': (context) => OpenFilePage(title: 'title'),
        '/file/recent': (context) => RecentFilesPage(title: 'title'),
        '/bookmarks': (context) => BookmarksPage(title: 'title'),
        '/manager': (context) => MemoryManagerPage(title: 'title'),
        '/help': (context) => HelpPage(title: 'title'),
        '/settings': (context) => SettingsPage(title: 'title'),
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
    SoftTrackMenuItem(Icons.select_all, 'Выделить всё'),
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
  late TextEditingController mainTextAreaController;
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
  int tabsCount = 1;
  String savedFileName = '';
  bool isDetectChanges = false;
  List monthLabels = [
    'янв.',
    'февр.',
    'мар.',
    'апр.',
    'мая',
    'июн.',
    'июл.',
    'авг.',
    'сен.',
    'окт.',
    'ноя.',
    'дек.'
  ];
  Color selectedStyleColor = Color.fromARGB(255, 255, 255, 255);
  String findDialogSearchContent = '';
  String findDialogReplacementContent = '';
  bool isPostInit = false;
  late TabBar openedDocumentsTabBar;
  String openedDocumentsHeader = 'Безымянный.txt';
  List <String> openedDocumentsHeaders = [
    'Безымянный.txt'
  ];
  TextEditingController savedFileController = TextEditingController();
  late DatabaseHandler handler;

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  bool getEnabled() {
    return !isReadOnly;
  }

  String get getOpenedDocumentsHeader {
    return openedDocumentsHeader;
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
      // TODO
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
                              setState(() {
                                findDialogSearchContent = value;
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
                            'Заменить на'
                        ),
                        TextField(
                            onChanged: (value) {
                              setState(() {
                                findDialogReplacementContent = value;
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
                      setState(() {
                        mainTextAreaContent = mainTextAreaContent.replaceFirst(findDialogSearchContent, findDialogReplacementContent);
                        mainTextAreaController.text = mainTextAreaContent;
                      });
                      return Navigator.pop(context, 'OK');
                    },
                    child: const Text('Заменить')
                ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        mainTextAreaContent = mainTextAreaContent.replaceAll(findDialogSearchContent, findDialogReplacementContent);
                        mainTextAreaController.text = mainTextAreaContent;
                      });
                      return Navigator.pop(context, 'OK');
                    },
                    child: const Text('Заменить все')
                ),
                TextButton(
                    onPressed: () {
                      int findIndex = mainTextAreaContent.indexOf(findDialogSearchContent);
                      if (findIndex != -1) {
                        int nextCharPosition = findIndex + 1;
                        mainTextAreaController.selection = TextSelection(
                            baseOffset: findIndex,
                            extentOffset: nextCharPosition
                        );
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Для \"${findDialogSearchContent}\" соответствий не найдено',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      return Navigator.pop(context, 'OK');
                    },
                    child: const Text('Найти')
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

      int currentDateMonthIndex = currentDateMonth - 1;
      String monthLabel = monthLabels[currentDateMonthIndex];
      String currentDateFormat = DateFormat('a').format(currentDate);
      var currentDateOffset = currentDate.timeZoneOffset;
      var currentDateOffsetInHours = currentDateOffset.inHours > 0 ? currentDateOffset.inHours : 1;
      String gmtLabel = '';
      if (!currentDateOffset.isNegative) {
        gmtLabel += '+' + currentDateOffset.inHours.toString().padLeft(2, '0') + ":" + (currentDateOffset.inMinutes % (currentDateOffsetInHours * 60)).toString().padLeft(2, '0');;
      } else {
        gmtLabel += '-' + (-currentDateOffset.inHours).toString().padLeft(2, '0') + ":" + (currentDateOffset.inMinutes % (currentDateOffsetInHours * 60)).toString().padLeft(2, '0');;
      }
      String rawFirstTimeStamp = '${rawCurrentDateYear}/${rawCurrentDateMonth}/${rawCurrentDateDay} ${rawCurrentDateHours}:${rawCurrentDateMinutes}';
      String rawSecondTimeStamp = '${rawCurrentDateYear}/${rawCurrentDateMonth}/${rawCurrentDateDay} ${rawCurrentDateHours}:${rawCurrentDateMinutes} ${currentDateFormat}';
      String rawThirdTimeStamp = '${rawCurrentDateYear}/${rawCurrentDateMonth}/${rawCurrentDateDay} ${rawCurrentDateHours}:${rawCurrentDateMinutes}:${rawCurrentDateSeconds} GMT ${gmtLabel}';
      String rawFourTimeStamp = '${rawCurrentDateMonth}/${rawCurrentDateDay}/${rawCurrentDateYear} ${rawCurrentDateHours}:${rawCurrentDateMinutes}';
      String rawFiveTimeStamp = '${rawCurrentDateMonth}/${rawCurrentDateDay}/${rawCurrentDateYear} ${rawCurrentDateHours}:${rawCurrentDateMinutes} ${currentDateFormat}';
      String rawSixTimeStamp = '${rawCurrentDateMonth}/${rawCurrentDateDay}/${rawCurrentDateYear} ${rawCurrentDateHours}:${rawCurrentDateMinutes}:${rawCurrentDateSeconds} GMT ${gmtLabel}';
      String rawSevenTimeStamp = '${monthLabel}/${rawCurrentDateDay}/${rawCurrentDateYear} ${rawCurrentDateHours}:${rawCurrentDateMinutes}';
      String rawEightTimeStamp = '${monthLabel}/${rawCurrentDateDay}/${rawCurrentDateYear} ${rawCurrentDateHours}:${rawCurrentDateMinutes} ${currentDateFormat}';
      String rawNineTimeStamp = '${monthLabel}/${rawCurrentDateDay}/${rawCurrentDateYear} ${rawCurrentDateHours}:${rawCurrentDateMinutes}:${rawCurrentDateSeconds} GMT ${gmtLabel}';
      String rawTenTimeStamp = '${rawCurrentDateDay}/${monthLabel}/${rawCurrentDateYear} ${rawCurrentDateHours}:${rawCurrentDateMinutes}';
      String rawElevenTimeStamp = '${rawCurrentDateDay}/${monthLabel}/${rawCurrentDateYear} ${rawCurrentDateHours}:${rawCurrentDateMinutes} ${currentDateFormat}';
      String rawTwelthTimeStamp = '${rawCurrentDateDay}/${monthLabel}/${rawCurrentDateYear} ${rawCurrentDateHours}:${rawCurrentDateMinutes}:${rawCurrentDateSeconds} GMT ${gmtLabel}';
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
                      return Navigator.pop(context, 'Cancel');
                    },
                    child: const Text('Отмена')
                ),
                TextButton(
                    onPressed: () {
                      String timeStamp = '';
                      if (selectedTimeStamp == TimeStampType.one) {
                        timeStamp = rawFirstTimeStamp;
                      } else if (selectedTimeStamp == TimeStampType.two) {
                        timeStamp = rawSecondTimeStamp;
                      } else if (selectedTimeStamp == TimeStampType.three) {
                        timeStamp = rawThirdTimeStamp;
                      } else if (selectedTimeStamp == TimeStampType.four) {
                        timeStamp = rawFourTimeStamp;
                      } else if (selectedTimeStamp == TimeStampType.five) {
                        timeStamp = rawFiveTimeStamp;
                      } else if (selectedTimeStamp == TimeStampType.six) {
                        timeStamp = rawSixTimeStamp;
                      } else if (selectedTimeStamp == TimeStampType.seven) {
                        timeStamp = rawSevenTimeStamp;
                      } else if (selectedTimeStamp == TimeStampType.eight) {
                        timeStamp = rawEightTimeStamp;
                      } else if (selectedTimeStamp == TimeStampType.nine) {
                        timeStamp = rawNineTimeStamp;
                      } else if (selectedTimeStamp == TimeStampType.ten) {
                        timeStamp = rawTenTimeStamp;
                      } else if (selectedTimeStamp == TimeStampType.eleven) {
                        timeStamp = rawElevenTimeStamp;
                      } else if (selectedTimeStamp == TimeStampType.twelth) {
                        timeStamp = rawTwelthTimeStamp;
                      }
                      setState(() {
                        mainTextAreaContent += timeStamp;
                        mainTextAreaController.text = mainTextAreaContent;
                      });
                      return Navigator.pop(context, 'Ok');
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
                      Color hexColor = ColorToHex(pickerColor);
                      String rawHexColor = hexColor.toString();
                      String hexColorCode = rawHexColor.substring(8, 16);
                      setState(() {
                        mainTextAreaContent += hexColorCode;
                        mainTextAreaController.text = mainTextAreaContent;
                      });
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
                      List<int> bytes = utf8.encode(mainTextAreaContent);
                      String convertedString = utf8.decode(bytes);
                      setState(() {
                        mainTextAreaContent = convertedString;
                      });
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
                      int mainTextAreaContentLength = mainTextAreaContent.length;
                      int selectionLength = mainTextAreaContentLength;
                      setState(() {
                        Iterable<Match> lines = '\n'.allMatches(mainTextAreaContent);
                        int findIndex = mainTextAreaContent.indexOf('\n');
                        if (findIndex != -1) {
                          mainTextAreaController.selection = TextSelection(
                              baseOffset: findIndex,
                              extentOffset: findIndex
                          );
                        }
                      });
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
                      setState(() {
                        if (selectedStyle == StyleType.Default) {
                          selectedStyleColor = Color.fromARGB(255, 255, 255, 255);
                        } else if (selectedStyle == StyleType.GitHub) {
                          selectedStyleColor = Color.fromARGB(255, 250, 250, 250);
                        } else if (selectedStyle == StyleType.GitHubv2) {
                          selectedStyleColor = Color.fromARGB(255, 245, 245, 245);
                        } else if (selectedStyle == StyleType.Tommorow) {
                          selectedStyleColor = Color.fromARGB(255, 240, 240, 240);
                        } else if (selectedStyle == StyleType.Hemisu) {
                          selectedStyleColor = Color.fromARGB(255, 245, 245, 245);
                        } else if (selectedStyle == StyleType.AtelierCave) {
                          selectedStyleColor = Color.fromARGB(255, 240, 240, 240);
                        } else if (selectedStyle == StyleType.AtelierDune) {
                          selectedStyleColor = Color.fromARGB(255, 235, 235, 235);
                        } else if (selectedStyle == StyleType.AtelierEstuary) {
                          selectedStyleColor = Color.fromARGB(255, 230, 230, 230);
                        } else if (selectedStyle == StyleType.AtelierForest) {
                          selectedStyleColor = Color.fromARGB(255, 225, 225, 225);
                        } else if (selectedStyle == StyleType.AtelierHeath) {
                          selectedStyleColor = Color.fromARGB(255, 220, 220, 220);
                        } else if (selectedStyle == StyleType.AtelierLakeside) {
                          selectedStyleColor = Color.fromARGB(255, 215, 215, 215);
                        } else if (selectedStyle == StyleType.AtelierPlateau) {
                          selectedStyleColor = Color.fromARGB(255, 210, 210, 210);
                        } else if (selectedStyle == StyleType.AtelierSavanna) {
                          selectedStyleColor = Color.fromARGB(255, 205, 205, 205);
                        } else if (selectedStyle == StyleType.AtelierSeaside) {
                          selectedStyleColor = Color.fromARGB(255, 200, 200, 200);
                        } else if (selectedStyle == StyleType.AtelierSulphurpool) {
                          selectedStyleColor = Color.fromARGB(255, 195, 195, 195);
                        }
                      });
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

    openAcceptExitDialog(context) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Выход'),
          content: Container(
            child: Column(
              children: [
                Text(
                  'Следующие файлы содержат\nнесохраненные изменения. Вы\nхотите сохранить их?'
                ),
                Row(
                  children: [
                    Icon(
                      Icons.folder,
                      size: 36
                    ),
                    Container(
                      child: Text(
                        'Безымянный.txt'
                      ),
                      margin: EdgeInsets.only(
                        left: 15
                      )
                    )
                  ]
                )
              ]
            )
          ),
          actions: [
            TextButton(
              child: Text(
                'Выход'
              ),
              onPressed: () {
                // закрываем файл
                setState(() {
                  mainTextAreaContent = '';
                  mainTextAreaController.text = mainTextAreaContent;
                  isDetectChanges = false;
                  SystemNavigator.pop();
                  exit(0);
                });
                return Navigator.pop(context, 'Cancel');
              }
            ),
            TextButton(
              child: Text(
                'Позже'
              ),
              onPressed: () {
                // закрываем только диалог
                return Navigator.pop(context, 'Cancel');
              }
            ),
            TextButton(
              child: Text(
                'Сохранить'
              ),
              onPressed: () {
                // сохраняем
                Navigator.pop(context, 'OK');
                setState(() {
                  savedFileName = openedDocumentsHeader;
                  savedFileController.text = savedFileName;
                });
                return openSaveDialog(context);
              }
            ),
          ]
        )
      );
    }

    openAcceptCloseDialog(context) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Сохранить'),
          content: Container(
              child: Text(
                  'Вы хотите сохранить изменения?'
              )
          ),
          actions: [
            TextButton(
              child: Text(
                'НЕТ'
              ),
              onPressed: () {
                // закрываем файл
                setState(() {
                  mainTextAreaContent = '';
                  mainTextAreaController.text = mainTextAreaContent;
                  isDetectChanges = false;
                });
                return Navigator.pop(context, 'Cancel');
              }
            ),
            TextButton(
                child: Text(
                  'ОТМЕНА'
                ),
                onPressed: () {
                  // закрываем только диалог
                  return Navigator.pop(context, 'Cancel');
                }
            ),
            TextButton(
                child: Text(
                    'ДА'
                ),
                onPressed: () {
                  // сохраняем
                  Navigator.pop(context, 'OK');
                  setState(() {
                    savedFileName = openedDocumentsHeader;
                    savedFileController.text = savedFileName;
                  });
                  return openSaveDialog(context);
                }
            ),
          ]
        )
      );
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Имя файла'
                      ),
                      Container(
                        width: 120,
                        child: TextField(
                          controller: savedFileController,
                          onChanged: (value) {
                            setState(() {
                              savedFileName = value;
                            });
                          },
                        )
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
                    onPressed: () async {
                      String appDir = await _localPath;
                      String filePath = '${appDir}/${savedFileName}';
                      var myFile = new File(filePath);
                      myFile.createSync();
                      myFile.writeAsString('abc');
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
          mainTextAreaController = TextEditingController(
              text: mainTextAreaContent
          );
          mainTextArea = TextField(
              controller: mainTextAreaController,
              onChanged: (value) {
                setState(() {
                  mainTextAreaContent = value;
                  numLines = '\n'.allMatches(value).length + 1;
                  isDetectChanges = true;
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

      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      bool isArgumentsExists = arguments != null;
      bool isNotPostInit = !isPostInit;
      bool isCanPostInit = isNotPostInit && isArgumentsExists;
      if (isCanPostInit) {
        String filePath = arguments['filePath'];
        var myFile = new File(filePath);
        myFile.readAsString().then((value) {
          String fileName = basename(filePath);
          setState(() {
            mainTextAreaContent = value;
            mainTextAreaController.text = mainTextAreaContent;
            openedDocumentsHeader = fileName;
            openedDocumentsHeaders[0] = fileName;
            isPostInit = true;
          });
        });
      } else {
        setState(() {
          isPostInit = true;
        });
      }

      return DefaultTabController(
          initialIndex: 0,
          length: tabsCount,
          child: WillPopScope(
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
                          // Navigator.pushNamed(context, '/file/open');
                          Navigator.pushNamed(
                              context,
                              '/file/open',
                              arguments: {
                                'filesAction': 'Открыть файл'
                              }
                          );
                        } else if (menuItemName.content == 'Открыть (SAF)') {
                          android_intent.Intent()
                            ..setAction(android_action.Action.ACTION_OPEN_DOCUMENT)
                            ..addCategory(Category.CATEGORY_OPENABLE)
                            ..setType("text/plain")
                            ..startActivity().catchError((e) => print('e: $e'));
                        } else if (menuItemName.content == 'Сохранить') {
                          if (isDetectChanges) {
                            openSaveDialog(context);
                          }
                        } else if (menuItemName.content == 'Сохранить как') {
                          // Navigator.pushNamed(context, '/file/open');
                          Navigator.pushNamed(
                              context,
                              '/file/open',
                              arguments: {
                                'filesAction': 'Сохранить как'
                              }
                          );
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
                        if (menuItemName.content == 'Выделить всё') {
                          int mainTextAreaContentLength = mainTextAreaContent.length;
                          int selectionLength = mainTextAreaContentLength;
                          setState(() {
                            mainTextAreaController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: selectionLength
                            );
                          });
                        } else if (menuItemName.content == 'Вставить') {
                          FlutterClipboard.paste().then((value) {
                            setState(() {
                              mainTextAreaContent += value;
                              mainTextAreaController.text = mainTextAreaContent;
                            });
                          });
                        } else if (menuItemName.content == 'Вставить цвет') {
                          openInsertColorDialog(context);
                        } else if (menuItemName.content == 'Вставить временную метку') {
                          openInsertTimeStampDialog(context);
                        } else if (menuItemName.content == 'Увеличить отступ') {
                          setState(() {
                            mainTextAreaContent = '\t${mainTextAreaContent}';
                            mainTextAreaController.text = mainTextAreaContent;
                          });
                        } else if (menuItemName.content == 'Уменьшить отступ') {
                          setState(() {
                            mainTextAreaContent = mainTextAreaContent.replaceFirst('\t', '');
                            mainTextAreaController.text = mainTextAreaContent;
                          });
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
                      setState(() {
                        currentTab = index;
                      });
                    },
                    tabs: <Widget>[
                      Tab(
                          text: getOpenedDocumentsHeader
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
                              // Navigator.pushNamed(context, '/file/open');
                              Navigator.pushNamed(
                                  context,
                                  '/file/open',
                                  arguments: {
                                    'filesAction': 'Открыть файл'
                                  }
                              );
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
                              if (isDetectChanges) {
                                openSaveDialog(context);
                              }
                            },
                            style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(
                                    (
                                        isDetectChanges ?
                                        Color.fromARGB(255, 0, 0, 0)
                                            :
                                        Color.fromARGB(255, 200, 200, 200)
                                    )
                                )
                            )
                        ),
                        TextButton(
                            child: Icon(
                                Icons.close,
                                color: (
                                    isDetectChanges ?
                                    Color.fromARGB(255, 0, 0, 0)
                                        :
                                    Color.fromARGB(255, 200, 200, 200)
                                )
                            ),
                            onPressed: () {
                              if (isDetectChanges) {
                                openAcceptCloseDialog(context);
                              }
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
                                    decoration: BoxDecoration(
                                        color: selectedStyleColor
                                    ),
                                    height: MediaQuery.of(context).size.height - 165,
                                    width: MediaQuery.of(context).size.width - 25,
                                    child: mainTextArea
                                )
                              ]
                          )
                      )
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
                                  Navigator.pushNamed(
                                      context,
                                      '/file/open',
                                      arguments: {
                                        'filesAction': 'Открыть файл'
                                      }
                                  );
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
                                  Navigator.pushNamed(context, '/manager');
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
                                onPressed: () async {
                                  // Убрать рекламу
                                  final String url = 'market://details?id=com.google.android.youtube';
                                  if (await canLaunch(url))
                                    await launch(url);
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
                                SystemNavigator.pop();
                                exit(0);
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
          ),
          onWillPop: () {
            return Future<bool>(() {
              if (isDetectChanges) {
                openAcceptExitDialog(context);
                return false;
              }
              return true;
            });
          },
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