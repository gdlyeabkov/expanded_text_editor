import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MemoryManagerPage extends StatefulWidget {
  const MemoryManagerPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MemoryManagerPage> createState() => _MemoryManagerPageState();
}

class _MemoryManagerPageState extends State<MemoryManagerPage> {
  @override
  Widget build(BuildContext context) {


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
                Navigator.pushNamed(context, '/file/open');
              }
            )
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: Icon(
          Icons.add
        ),
        backgroundColor: Color.fromARGB(255, 0, 150, 0)
      ),
    );
  }

}