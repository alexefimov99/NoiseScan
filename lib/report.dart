import 'dart:async';
// import 'dart:html';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_first_app0/myhomepage.dart';
import 'package:flutter_first_app0/reportfiled.dart';
import 'package:flutter_first_app0/reporttable.dart';

import 'package:path_provider/path_provider.dart';
// import 'package:url_launcher/url_launcher.dart';

import 'package:permission_handler/permission_handler.dart';

//Костылим за нехваткой знаний
late String str;

class Report extends StatelessWidget
{
  final List<Map<int, double> >lmResult;

  const Report(
      {required this.lmResult, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top:25, left:10, right:10),
        color: Color.fromARGB(255, 75, 75, 75),
        child: Text(
            outputReport(lmResult, context),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: TextStyle(color: Color.fromARGB(255, 213, 138, 0),
                fontSize: 20,
                decoration: TextDecoration.none,
            )
          )
        // child: outputReport(lmResult, context),
        ),
        ////////////////////////////////////////////
        /// Кнопка для выгрузки значений
        Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              child: const Text("Сохранить отчёт"),
              // onPressed: saveReport,
              onPressed: () {
                saveReport(context);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 228, 129, 0),
                ),
              ),
            ),
          ),
          ////////////////////////////////////////////
      ],
    );
  }
}

// Вывод нескольких измерений на экран
// Table outputReport(List<Map<int, double> > lValues, BuildContext context)
String outputReport(List<Map<int, double> > lValues, BuildContext context)
{
  String result = '\n'; // Перенос нужен для более читаемого отображения на устройстве

  List<List<String> >splitStrings = [];

  // List<String> splitString;
  for(int i = 0; i < lValues.length; i++)
  {
    String temp = lValues[i].toString().replaceAll('{', '').replaceAll('}', '');

    result += temp + '\n\n';
    
    splitStrings.add(temp.split(', '));
  }
  print('result: ${result}');


  str = result;

  CreateTable(splitStrings, context);

  // return Table();
  return result;
}

void saveReport(BuildContext context) async
{
  // if(await Permission.manageExternalStorage.request().isGranted)
  // {
  //   print('manageExernalStorage permission');
  // }
  
  // Проверка на права доступа к хранилищу устройства
  if(await Permission.storage.request().isGranted)
  { }

  // Берем директорию приложения
  var dir = await getExternalStorageDirectory();

  String fileName = 'Report.docx';
  String saveFolder = 'documents';

  if(dir != null)
  {
    // Ни в коем случае не костыль, идем в корень к документам (см. if() ниже)
    dir = dir.parent.parent.parent.parent;

    if(await Directory(dir.path + '/$saveFolder').exists())
    {
      dir = Directory('${dir.path}/$saveFolder');

      var file = File('${dir.path}/${fileName}');
      file.writeAsString('$str');
    }
    else
    {
      const String message = 'Путь не найден или данной директории не существует.';

      // В случае какой-то проблемы будет выведено сообщение
      OutputMessage(context, message);
    }
  }
  else
  {
    const String message = 'Переменная с указателем пути по какой-то причине равна нулю';

    // В случае какой-то проблемы будет выведено сообщение
    OutputMessage(context, message);
  }
}