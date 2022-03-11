import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unicorndial/unicorndial.dart';

class MemoryManagerPage extends StatefulWidget {
  const MemoryManagerPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MemoryManagerPage> createState() => _MemoryManagerPageState();
}

class _MemoryManagerPageState extends State<MemoryManagerPage> {
  @override
  Widget build(BuildContext context) {

    final List<UnicornButton> floatingButtons = [];

    floatingButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "FTP/FTPS/SFTP",
        labelBackgroundColor: Color.fromARGB(255, 100, 100, 100),
        labelColor: Colors.white,
        currentButton: FloatingActionButton(
          heroTag: "attachment",
          backgroundColor: Color.fromARGB(255, 0, 185, 0),
          mini: true,
          child: Icon(Icons.graphic_eq),
          onPressed: () {
            print('FTP/FTPS/SFTP');
          },
        ),
      ),
    );
    floatingButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "WebDAV",
        labelBackgroundColor: Color.fromARGB(255, 100, 100, 100),
        labelColor: Colors.white,
        currentButton: FloatingActionButton(
          heroTag: "attachment",
          backgroundColor: Color.fromARGB(255, 0, 185, 0),
          mini: true,
          child: Icon(Icons.circle),
          onPressed: () {
            print('Attachment FAB clicked');
          },
        ),
      ),
    );
    floatingButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "Dropbox",
        labelBackgroundColor: Color.fromARGB(255, 100, 100, 100),
        labelColor: Colors.white,
        currentButton: FloatingActionButton(
          heroTag: "attachment",
          backgroundColor: Color.fromARGB(255, 0, 185, 0),
          mini: true,
          child: Image.asset(
            'assets/dropbox.png',
            width: 25,
            height: 25,
            color: Colors.white
          ),
          onPressed: () {
            print('Attachment FAB clicked');
          },
        ),
      ),
    );
    floatingButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "Google Drive",
        labelBackgroundColor: Color.fromARGB(255, 100, 100, 100),
        labelColor: Colors.white,
        currentButton: FloatingActionButton(
          heroTag: "attachment",
          backgroundColor: Color.fromARGB(255, 0, 185, 0),
          mini: true,
          child: Image.asset(
            'assets/google_drive.png',
            width: 25,
            height: 25,
            color: Colors.white
          ),
          onPressed: () {
            print('Attachment FAB clicked');
          },
        ),
      ),
    );
    floatingButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "OneDrive",
        labelBackgroundColor: Color.fromARGB(255, 100, 100, 100),
        labelColor: Colors.white,
        currentButton: FloatingActionButton(
          heroTag: "attachment",
          backgroundColor: Color.fromARGB(255, 0, 185, 0),
          mini: true,
          child: Image.asset(
            'assets/onedrive.png',
            width: 25,
            height: 25,
            color: Colors.white
          ),
          onPressed: () {
            print('Attachment FAB clicked');
          },
        ),
      ),
    );
    floatingButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "GitHub",
        labelBackgroundColor: Color.fromARGB(255, 100, 100, 100),
        labelColor: Colors.white,
        currentButton: FloatingActionButton(
          onPressed: () {
            print('Camera FAB clicked');
          },
          heroTag: "camera",
          backgroundColor: Color.fromARGB(255, 0, 185, 0),
          mini: true,
          child: Image.asset(
            'assets/github.png',
            width: 25,
            height: 25,
            color: Colors.white
          ),
        ),
      ),
    );
    floatingButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "GitLab",
        labelBackgroundColor: Color.fromARGB(255, 100, 100, 100),
        labelColor: Colors.white,
        currentButton: FloatingActionButton(
          onPressed: () {
            print('Note FAB clicked');
          },
          heroTag: "note",
          backgroundColor: Color.fromARGB(255, 0, 185, 0),
          mini: true,
          child: Image.asset(
            'assets/gitlab.png',
            width: 25,
            height: 25,
            color: Colors.white
          )
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Диспетчер памяти'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              child: Row(
                children: [
                  Icon(
                    Icons.phone_android
                  ),
                  Container(
                    child: Column(
                      children: [
                        Text(
                          'Внутренняя память'
                        ),
                        Text(
                          'storage/emulated/0',
                          style: TextStyle(
                            color: Color.fromARGB(255, 150, 150, 150)
                          )
                        ),
                      ]
                    ),
                    margin: EdgeInsets.only(
                      left: 15
                    )
                  )
                ]
              ),
              onTap: () {
                // Navigator.pushNamed(context, '/file/open');
                Navigator.pushNamed(
                  context,
                  '/file/open',
                  arguments: {
                    'filesAction': 'Открыть файл'
                  }
                );
              }
            )
          ]
        ),
      ),
      floatingActionButton: UnicornDialer(
        backgroundColor: Colors.transparent,
        parentButtonBackground: Color.fromARGB(255, 0, 185, 0),
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(Icons.add),
        childButtons: floatingButtons
      )
    );
  }

}