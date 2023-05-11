import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text('Текстовый редактор'),
        actions: [
          FlatButton(
            onPressed: () {

            },
            child: Icon(
              Icons.home
            )
          )
        ]
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Text(
                'текстовый редактор',
                style: TextStyle(
                  color: Color.fromARGB(255, 150, 150, 150),
                  fontSize: 24
                ),
                textAlign: TextAlign.center
              ),
              Container(
                child: Text(
                  'Добро пожаловать в текстовый\nредактор справочныйцентр.',
                  style: TextStyle(
                    fontSize: 18
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
                      'НАЧИНАЯ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400
                      )
                    ),
                    Divider(),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Введение',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                            Icons.folder,
                            color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Журнал изменений',
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Мултиязычность',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                              left: 15
                          ),
                        )
                      ],
                    )
                  ],
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
                      'НАВИГАЦИЯ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400
                      )
                    ),
                    Divider(),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Панель навигации',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Панель каталога',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                              left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Панель инструментов',
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    )
                  ],
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
                      'ФАЙЛ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400
                      )
                    ),
                    Divider(),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Открыть файл',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Сохранить файл',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                              left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Управление хранилищем',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Недавние файлы',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Закладки',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    )
                  ],
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
                      'РЕДАКТИРОВАНИЕ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400
                      )
                    ),
                    Divider(),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Выделение',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          )
                        )
                      ]
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Отменить/повторить',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          )
                        )
                      ]
                    ),
                    Row(
                      children: [
                        Icon(
                            Icons.folder,
                            color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Поиск/замена',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          )
                        )
                      ]
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Вставить цвет',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Редактирование данных на Android',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
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
                      'РАСШИРЕННОЕ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400
                      )
                    ),
                    Divider(),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Синтаксис языка',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Кодировка',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Клавиатурные сокращения',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                              left: 15
                          ),
                        )
                      ],
                    )
                  ],
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
                      'ДРУГОЕ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400
                      )
                    ),
                    Divider(),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Настройки',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Убрать рекламу',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'Лицензии',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color.fromARGB(255, 0, 230, 100)
                        ),
                        Container(
                          child: Text(
                            'ЧАВО',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 230, 100)
                            )
                          ),
                          margin: EdgeInsets.only(
                            left: 15
                          ),
                        )
                      ],
                    ),
                  ]
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 15
                )
              )
            ]
          )
        )
      )
    );
  }

}