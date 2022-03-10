import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
              Container(
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
              Container(
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
              Container(
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
              Container(
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
                      value: true,
                      onChanged: (value) {

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
                      value: true,
                      onChanged: (value) {

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
                      value: true,
                      onChanged: (value) {

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
                      value: true,
                      onChanged: (value) {

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
                      value: true,
                      onChanged: (value) {

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
                      value: true,
                      onChanged: (value) {

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
              Container(
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
                      value: true,
                      onChanged: (value) {

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
                      value: true,
                      onChanged: (value) {

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
                      value: true,
                      onChanged: (value) {

                      },
                      activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                      activeColor: Color.fromARGB(255, 0, 150, 0),
                    )
                  ]
                )
              ),
              Container(
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
              Container(
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
              Container(
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
              Text(
                'Автосохранение',
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
                      value: true,
                      onChanged: (value) {

                      },
                      activeTrackColor: Color.fromARGB(255, 0, 235, 50),
                      activeColor: Color.fromARGB(255, 0, 150, 0),
                    )
                  ]
                )
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Интервал автосохранения',
                      style: TextStyle(
                        fontSize: 16
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
              Text(
                'Внешний вид',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 0, 150, 0)
                )
              ),
              Container(
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
                      value: true,
                      onChanged: (value) {

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
              Container(
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
              Container(
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
              Container(
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
              )
            ],
          )
        )
      )
    );
  }

}