import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool isWordsWrap = false;
  bool isShowFoldersPanel = false;
  bool isAutoOffset = false;
  bool isCancelBackBtn = false;
  bool isFilterFiles = false;
  bool isRecoverySession = false;
  bool isAutoUppercase = false;
  bool isAuxKeyboard = false;
  bool isShowNumberLines = false;
  bool isAutoSave = false;
  LangType selectedLang = LangType.auto;
  EncodingType selectedEncoding = EncodingType.utf8;
  BreakLineType selectedBreakLine = BreakLineType.auto;
  ParagraphCharType selectedParagraphChar = ParagraphCharType.tab;
  String paragraphCharSpacesCount = '';
  HintsType selectedHints = HintsType.disabled;
  FontFamilyType selectedFontFamily = FontFamilyType.normal;
  double fontSize = 18.0;
  double lineHeight = 2.0;
  AutoSaveIntervalType selectedAutoSaveInterval = AutoSaveIntervalType.mins1;
  ThemeType selectedTheme = ThemeType.light;
  bool isFullScreen = false;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Text(
                'Общие настройки',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 0, 150, 0)
                )
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Язык',
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        'Авто (По умолчанию).',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      )
                    ]
                  )
                ),
                onTap: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Язык'),
                      content: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Radio<LangType>(
                                  value: LangType.auto,
                                  groupValue: selectedLang,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLang = value!;
                                    });
                                  },
                                ),
                                Text(
                                    'Авто (По умолчанию)'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<LangType>(
                                  value: LangType.rus,
                                  groupValue: selectedLang,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLang = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Русский'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<LangType>(
                                  value: LangType.eng,
                                  groupValue: selectedLang,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLang = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Английский'
                                )
                              ]
                            ),
                          ]
                        )
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            return Navigator.pop(context, 'OK');
                          },
                          child: const Text('ОТМЕНА')
                        )
                      ]
                    )
                  );
                }
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Кодировка по умолчанию',
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        'Кодировка по умолчанию при открытии и\nсоздании файлов.',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      )
                    ]
                  )
                ),
                onTap: () {
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
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сопоставление файлов',
                      style: TextStyle(
                        fontSize: 16
                      )
                    ),
                    Text(
                      'Укажите расширения файлов для сопоставления с\nдоступными редакторами',
                      style: TextStyle(
                        color: Color.fromARGB(255, 200, 200, 200)
                      )
                    )
                  ]
                )
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Разрыв строки',
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        'Символ разрыва строки при сохранении файлов.',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      )
                    ]
                  )
                ),
                onTap: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Символ абзаца'),
                      content: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Radio<BreakLineType>(
                                  value: BreakLineType.auto,
                                  groupValue: selectedBreakLine,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBreakLine = selectedBreakLine!;
                                    });
                                  },
                                ),
                                Text(
                                  'Авто (По умолчанию)'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<BreakLineType>(
                                  value: BreakLineType.linux,
                                  groupValue: selectedBreakLine,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBreakLine = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Android, Linux, OS X (\\n)'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<BreakLineType>(
                                  value: BreakLineType.windows,
                                  groupValue: selectedBreakLine,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBreakLine = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Windows (\\r\\n)'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<BreakLineType>(
                                  value: BreakLineType.macos,
                                  groupValue: selectedBreakLine,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBreakLine = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Mac OS (\\r)'
                                )
                              ]
                            )
                          ]
                        )
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            return Navigator.pop(context, 'OK');
                          },
                          child: const Text('ОТМЕНА')
                        )
                      ]
                    )
                  );
                }
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Символ абзаца',
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        'Символ строки, используемый при отступе.',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      )
                    ]
                  )
                ),
                onTap: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Показывать подсказки'),
                      content: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Radio<ParagraphCharType>(
                                  value: ParagraphCharType.tab,
                                  groupValue: selectedParagraphChar,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedParagraphChar = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Символ табуляции'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<ParagraphCharType>(
                                  value: ParagraphCharType.spaceChars,
                                  groupValue: selectedParagraphChar,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedParagraphChar = value!;
                                    });
                                  },
                                ),
                                Row(
                                  children: [
                                    // TextField(
                                    //   onChanged: (value) {
                                    //     setState(() {
                                    //       paragraphCharSpacesCount = value;
                                    //     });
                                    //   },
                                    //   decoration: new InputDecoration.collapsed(
                                    //     hintText: '',
                                    //     border: OutlineInputBorder(
                                    //       borderSide: BorderSide(
                                    //         width: 0.0,
                                    //         color: Colors.transparent,
                                    //         style: BorderStyle.none
                                    //       )
                                    //     )
                                    //   )
                                    // ),
                                    Text(
                                      'знака(ов) пробела'
                                    ),
                                  ]
                                )
                              ]
                            )
                          ]
                        )
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            return Navigator.pop(context, 'OK');
                          },
                          child: const Text('ОТМЕНА')
                        )
                      ]
                    )
                  );
                }
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Перенос по словам',
                          style: TextStyle(
                            fontSize: 16
                          )
                        ),
                        Text(
                          'Включить перенос слов по ширине\nэкрана.',
                          style: TextStyle(
                            color: Color.fromARGB(255, 200, 200, 200)
                          )
                        )
                      ]
                    ),
                    Switch(
                      value: isWordsWrap,
                      onChanged: (value) {
                        setState(() {
                          isWordsWrap = !isWordsWrap;
                        });
                      },
                      activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                      activeColor: Color.fromARGB(255, 0, 150, 0),
                    )
                  ]
                )
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Панель папок',
                          style: TextStyle(
                            fontSize: 16
                          )
                        ),
                        Text(
                          'Включить панель навигации по папкам на\nглавном экране.',
                          style: TextStyle(
                            color: Color.fromARGB(255, 200, 200, 200)
                          )
                        )
                      ]
                    ),
                    Switch(
                      value: isShowFoldersPanel,
                      onChanged: (value) {
                        setState(() {
                          isShowFoldersPanel = !isShowFoldersPanel;
                        });
                      },
                      activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                      activeColor: Color.fromARGB(255, 0, 150, 0),
                    )
                  ]
                )
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Автоотступ',
                          style: TextStyle(
                            fontSize: 16
                          )
                        ),
                        Text(
                          'Включить автоматический отступ для\nновых строк.',
                          style: TextStyle(
                            color: Color.fromARGB(255, 200, 200, 200)
                          )
                        )
                      ]
                    ),
                    Switch(
                      value: isAutoOffset,
                      onChanged: (value) {
                        setState(() {
                          isAutoOffset = !isAutoOffset;
                        });
                      },
                      activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                      activeColor: Color.fromARGB(255, 0, 150, 0),
                    )
                  ]
                )
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Отмена кнопкой \"Назад\"',
                          style: TextStyle(
                            fontSize: 16
                          )
                        ),
                        Text(
                          'Отменять посленднее изменение с\nпомощью кнопки \"Назад\".',
                          style: TextStyle(
                            color: Color.fromARGB(255, 200, 200, 200)
                          )
                        )
                      ]
                    ),
                    Switch(
                      value: isCancelBackBtn,
                      onChanged: (value) {
                        setState(() {
                          isCancelBackBtn = !isCancelBackBtn;
                        });
                      },
                      activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                      activeColor: Color.fromARGB(255, 0, 150, 0),
                    )
                  ]
                )
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Фильтр файлов',
                          style: TextStyle(
                            fontSize: 16
                          )
                        ),
                        Text(
                          'Скрывать нетекстовые файлы при\nоткрытии файлов.',
                          style: TextStyle(
                            color: Color.fromARGB(255, 200, 200, 200)
                          )
                        )
                      ]
                    ),
                    Switch(
                      value: isFilterFiles,
                      onChanged: (value) {
                        setState(() {
                          isFilterFiles = !isFilterFiles;
                        });
                      },
                      activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                      activeColor: Color.fromARGB(255, 0, 150, 0),
                    )
                  ]
                )
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Возобновление сеанса',
                          style: TextStyle(
                            fontSize: 16
                          )
                        ),
                        Text(
                          'Восстанавливать открытые файлы при\nследующем запуске приложения.',
                          style: TextStyle(
                            color: Color.fromARGB(255, 200, 200, 200)
                          )
                        )
                      ]
                    ),
                    Switch(
                      value: isRecoverySession,
                      onChanged: (value) {
                        setState(() {
                          isRecoverySession = !isRecoverySession;
                        });
                      },
                      activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                      activeColor: Color.fromARGB(255, 0, 150, 0),
                    )
                  ]
                )
              ),
              Text(
                'Способ ввода',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 0, 150, 0)
                )
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Показывать подсказки',
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        'Предлагать варианты слов во время ввода: ОТКЛ.\n(По умолчанию).',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      )
                    ]
                  )
                ),
                onTap: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Показывать подсказки'),
                      content: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Radio<HintsType>(
                                  value: HintsType.enabled,
                                  groupValue: selectedHints,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedHints = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'ВКЛ.'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<HintsType>(
                                  value: HintsType.disabled,
                                  groupValue: selectedHints,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedHints = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'ОТКЛ. (По умолчанию)'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<HintsType>(
                                  value: HintsType.fullDisabled,
                                  groupValue: selectedHints,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedHints = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'ОТКЛ. (Принудительно)'
                                )
                              ]
                            ),
                          ]
                        )
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            return Navigator.pop(context, 'OK');
                          },
                          child: const Text('ОТМЕНА')
                        )
                      ]
                    )
                  );
                }
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Заглавные автоматически',
                          style: TextStyle(
                              fontSize: 16
                          )
                        ),
                        Text(
                          'Писать первое слово предложения с\nпрописной буквы.',
                          style: TextStyle(
                            color: Color.fromARGB(255, 200, 200, 200)
                          )
                        )
                      ]
                    ),
                    Switch(
                      value: isAutoUppercase,
                      onChanged: (value) {
                        setState(() {
                          isAutoUppercase = !isAutoUppercase;
                        });
                      },
                      activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                      activeColor: Color.fromARGB(255, 0, 150, 0),
                    )
                  ]
                )
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Дополнительная клавиатура',
                          style: TextStyle(
                            fontSize: 16
                          )
                        ),
                        Text(
                          'Показывать дополнительную клавиатуру\nпод редактором.',
                          style: TextStyle(
                            color: Color.fromARGB(255, 200, 200, 200)
                          )
                        )
                      ]
                    ),
                    Switch(
                      value: isAuxKeyboard,
                      onChanged: (value) {
                        setState(() {
                          isAuxKeyboard = !isAuxKeyboard;
                        });
                      },
                      activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                      activeColor: Color.fromARGB(255, 0, 150, 0),
                    )
                  ]
                )
              ),
              Text(
                'Параметры просмотра',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 0, 150, 0)
                )
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Номера строк',
                          style: TextStyle(
                            fontSize: 16
                          )
                        ),
                        Text(
                          'Показывать номера строк.',
                          style: TextStyle(
                              color: Color.fromARGB(255, 200, 200, 200)
                          )
                        )
                      ]
                    ),
                    Switch(
                      value: isShowNumberLines,
                      onChanged: (value) {
                        setState(() {
                          isShowNumberLines = !isShowNumberLines;
                        });
                      },
                      activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                      activeColor: Color.fromARGB(255, 0, 150, 0),
                    )
                  ]
                )
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Тип шрифта',
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        'Тип шрифта для редактирования текста: Обычный\n(По умолчанию).',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      )
                    ]
                  )
                ),
                onTap: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Тип шрифта'),
                      content: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Radio<FontFamilyType>(
                                  value: FontFamilyType.normal,
                                  groupValue: selectedFontFamily,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedFontFamily = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Обычный (По умолчанию)'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<FontFamilyType>(
                                  value: FontFamilyType.sansSerif,
                                  groupValue: selectedFontFamily,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedFontFamily = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Sans Serif'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<FontFamilyType>(
                                  value: FontFamilyType.serif,
                                  groupValue: selectedFontFamily,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedFontFamily = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Serif'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<FontFamilyType>(
                                  value: FontFamilyType.monospace,
                                  groupValue: selectedFontFamily,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedFontFamily = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Monospace'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<FontFamilyType>(
                                  value: FontFamilyType.external,
                                  groupValue: selectedFontFamily,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedFontFamily = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Внешний'
                                )
                              ]
                            ),
                          ]
                        )
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            return Navigator.pop(context, 'OK');
                          },
                          child: const Text('ОТМЕНА')
                        )
                      ]
                    )
                  );
                }
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Размер шрифта',
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        'Размер шрифта для редактировани текста: 18sp.',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      )
                    ]
                  )
                ),
                onTap: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Размер шрифта'),
                      content: Container(
                        child: Column(
                          children: [
                            Slider(
                              onChanged: (double value) {
                                setState(() {
                                  fontSize = value!;
                                });
                              },
                              value: fontSize,
                              min: 8,
                              max: 56
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '8'
                                ),
                                Text(
                                  '56'
                                )
                              ]
                            )
                          ]
                        )
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            return Navigator.pop(context, 'OK');
                          },
                          child: const Text('ОТМЕНА')
                        )
                      ]
                    )
                  );
                }
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Интервал между строками',
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        'Междустрочный интервал для редактирования\nтекста: 2sp.',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      )
                    ]
                  )
                ),
                onTap: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Интервал между строками'),
                      content: Container(
                        child: Column(
                          children: [
                            Slider(
                              onChanged: (double value) {
                                setState(() {
                                  lineHeight = value!;
                                });
                              },
                              value: lineHeight,
                              min: 0,
                              max: 6
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '0'
                                ),
                                Text(
                                  '6'
                                )
                              ]
                            )
                          ]
                        )
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            return Navigator.pop(context, 'OK');
                          },
                          child: const Text('ОТМЕНА')
                        )
                      ]
                    )
                  );
                }
              ),
              Text(
                'Автосохранение',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 0, 150, 0)
                )
              ),
              GestureDetector(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Автосохранение',
                            style: TextStyle(
                              fontSize: 16
                            )
                          ),
                          Text(
                            'Автоматически сохранять изменения.',
                            style: TextStyle(
                              color: Color.fromARGB(255, 200, 200, 200)
                            )
                          )
                        ]
                      ),
                      Switch(
                        value: isAutoSave,
                        onChanged: (value) {
                          setState(() {
                            isAutoSave = !isAutoSave;
                          });
                        },
                        activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                        activeColor: Color.fromARGB(255, 0, 150, 0),
                      )
                    ]
                  )
                ),
                onTap:() {
                  setState(() {
                    isAutoSave = !isAutoSave;
                  });
                }
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Интервал автосохранения',
                        style: TextStyle(
                          fontSize: 16,
                          color: (
                            isAutoSave ?
                              Color.fromARGB(255, 0, 0, 0)
                            :
                              Color.fromARGB(255, 200, 200, 200)
                          )
                        )
                      ),
                      Text(
                        'Частота автосохранения: 1 мин (По умолчанию).',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      )
                    ]
                  )
                ),
                onTap: () {
                  if (isAutoSave) {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Интервал автосохранения'),
                        content: Container(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Radio<AutoSaveIntervalType>(
                                    value: AutoSaveIntervalType.mins0secondss30,
                                    groupValue: selectedAutoSaveInterval,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAutoSaveInterval = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    '30 сек'
                                  )
                                ]
                              ),
                              Row(
                                children: [
                                  Radio<AutoSaveIntervalType>(
                                    value: AutoSaveIntervalType.mins1,
                                    groupValue: selectedAutoSaveInterval,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAutoSaveInterval = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    '1 мин (По умолчанию)'
                                  )
                                ]
                              ),
                              Row(
                                children: [
                                  Radio<AutoSaveIntervalType>(
                                    value: AutoSaveIntervalType.mins3,
                                    groupValue: selectedAutoSaveInterval,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAutoSaveInterval = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    '3 мин'
                                  )
                                ]
                              ),
                              Row(
                                children: [
                                  Radio<AutoSaveIntervalType>(
                                    value: AutoSaveIntervalType.mins5,
                                    groupValue: selectedAutoSaveInterval,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAutoSaveInterval = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    '5 мин'
                                  )
                                ]
                              ),
                              Row(
                                children: [
                                  Radio<AutoSaveIntervalType>(
                                    value: AutoSaveIntervalType.mins10,
                                    groupValue: selectedAutoSaveInterval,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAutoSaveInterval = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    '10 мин'
                                  )
                                ]
                              ),
                            ]
                          )
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              return Navigator.pop(context, 'OK');
                            },
                            child: const Text('ОТМЕНА')
                          )
                        ]
                      )
                    );
                  }
                }
              ),
              Text(
                'Внешний вид',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 0, 150, 0)
                )
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Тема',
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        'Выберите предпочтительную тему приложения.',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      )
                    ]
                  )
                ),
                onTap: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Тема'),
                      content: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Radio<ThemeType>(
                                  value: ThemeType.light,
                                  groupValue: selectedTheme,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedTheme = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Светлая'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<ThemeType>(
                                  value: ThemeType.dark,
                                  groupValue: selectedTheme,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedTheme = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Темная'
                                )
                              ]
                            ),
                            Row(
                              children: [
                                Radio<ThemeType>(
                                  value: ThemeType.black,
                                  groupValue: selectedTheme,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedTheme = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Черная'
                                )
                              ]
                            ),
                          ]
                        )
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            return Navigator.pop(context, 'OK');
                          },
                          child: const Text('ОТМЕНА')
                        )
                      ]
                    )
                  );
                }
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Во весь экран',
                          style: TextStyle(
                            fontSize: 16
                          )
                        ),
                        Text(
                          'Открывать приложение в полноэкранном\nрежиме.',
                          style: TextStyle(
                            color: Color.fromARGB(255, 200, 200, 200)
                          )
                        )
                      ]
                    ),
                    Switch(
                      value: isFullScreen,
                      onChanged: (value) {
                        setState(() {
                          isFullScreen = !isFullScreen;
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Во весь экран'),
                              content: Container(
                                child: Column(
                                  children: [
                                    Text(
                                      'Этот параметр будет применен\nпосле перезапуска приложения.'
                                    ),
                                  ]
                                )
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    return Navigator.pop(context, 'OK');
                                  },
                                  child: const Text('ОК')
                                )
                              ]
                            )
                          );
                        });
                      },
                      activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                      activeColor: Color.fromARGB(255, 0, 150, 0),
                    )
                  ]
                )
              ),
              Container(
                child: Text(
                  'О программе',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color.fromARGB(255, 0, 150, 0)
                  )
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 15
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Версия',
                      style: TextStyle(
                        fontSize: 16
                      )
                    ),
                    Text(
                      '1.0.0',
                      style: TextStyle(
                        color: Color.fromARGB(255, 200, 200, 200)
                      )
                    )
                  ]
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 15
                )
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Разработчик',
                      style: TextStyle(
                        fontSize: 16
                      )
                    ),
                    Text(
                      'Softtrack',
                      style: TextStyle(
                        color: Color.fromARGB(255, 200, 200, 200)
                      )
                    )
                  ]
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 15
                )
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Следить за новостями',
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        'Следите за нашими новостями на Facebook.',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      )
                    ]
                  ),
                  margin: EdgeInsets.symmetric(
                      vertical: 15
                  )
                ),
                onTap: () async {
                  final String url = 'https://www.facebook.com/QuickEditTextEditor';
                  if (await canLaunch(url))
                    await launch(url);
                }
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Отправить отзыв',
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        'Сообщите о проблеме на форуме',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      )
                    ]
                  ),
                  margin: EdgeInsets.symmetric(
                    vertical: 15
                  )
                ),
                onTap: () async {
                  final String url = 'https://forum.xda-developers.com/t/app-4-0-3-quickedit-text-editor.2899385/';
                  if (await canLaunch(url))
                    await launch(url);
                }
              ),
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Убрать рекламу',
                        style: TextStyle(
                          fontSize: 16
                        )
                      ),
                      Text(
                        'Скачать версию без рекламы из Google Play.',
                        style: TextStyle(
                          color: Color.fromARGB(255, 200, 200, 200)
                        )
                      ),
                    ]
                  ),
                  margin: EdgeInsets.symmetric(
                      vertical: 15
                  ),
                ),
                onTap: () async {
                  // Убрать рекламу
                  final String url = 'market://details?id=com.google.android.youtube';
                  if (await canLaunch(url))
                    await launch(url);
                }
              )
            ],
          )
        )
      )
    );
  }

}