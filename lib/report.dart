import 'dart:async';
// import 'dart:html';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_first_app0/myhomepage.dart';
import 'package:flutter_first_app0/reportfiled.dart';

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
            StringReport(lmResult, context),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: TextStyle(color: Color.fromARGB(255, 213, 138, 0),
                fontSize: 20,
                decoration: TextDecoration.none,
            )
          )
        // child: StringReport(lmResult, context),
        ),
        ////////////////////////////////////////////
        /// Кнопка для выгрузки значений
        Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              child: const Text("Сохранить отчёт (Фон)"),
              // onPressed: SaveReport,
              onPressed: () {
                SaveReport(context, false);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 228, 129, 0),
                ),
              ),
            ),
          ),
        Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              child: const Text("Сохранить отчёт (Шум + голос)"),
              // onPressed: SaveReport,
              onPressed: () {
                SaveReport(context, true);
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
// Table StringReport(List<Map<int, double> > lValues, BuildContext context)
String StringReport(List<Map<int, double> > lValues, BuildContext context)
{
  String result = '\n'; // Перенос нужен для более читаемого отображения на устройстве

  List<List<String> >splitStrings = [];
  for(int i = 0; i < lValues.length; i++)
  {
    String temp = lValues[i].toString().replaceAll('{', '').replaceAll('}', '');
    
    result += temp + ((i != lValues.length - 1) ? ('\n\n') : ('\n'));
    
    splitStrings.add(temp.split(', '));
  }

  // str = result;

  // return CreateTable(splitStrings, context);
  return ReportView(splitStrings);
}

void SaveReport(BuildContext context, bool buttonID) async
{
  // Проверка на права доступа к хранилищу устройства
  if(await Permission.manageExternalStorage.request().isGranted)
  { }
  if(await Permission.storage.request().isGranted)
  { }

  // Берем директорию приложения
  var dir = await getExternalStorageDirectory();

  // String fileName = 'Отчет.docx';
  String fileName = ((!buttonID) ? ('Отчет_Фон.txt') : ('Отчет_Шум_Голос.txt'));
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

String ReportView(List<List<String> > llValues)
{
  String result = '\nШум\n\nОктавные полосы частот f,\nГц    \tдБ\n';
  List<double> arithMean = List.filled(7, 0);

  print('ReportVew ${llValues.length}\n${llValues[0].length}');
  
  for(int i = 0; i < llValues.length; i++)
  {
    for(int j = 0; j < llValues[i].length; j++)
    {
      llValues[i][j] = llValues[i][j].replaceAll(RegExp(r'[0-9]*: '), '').replaceAll(' ', '');
      // print('${i + 1}.${j + 1}: ${llValues[i][j]}');

      arithMean[j] += double.parse(llValues[i][j]);
    }
  }

  for(int i = 0; i < arithMean.length; i++)
  {
    arithMean[i] = arithMean[i] / llValues.length;
    result += '${lHz[i]}:${((lHz[i] > 500) ? ('  '):('   '))}${arithMean[i].toStringAsFixed(2)}\n';
    // print('${arithMean[i]}');
  }

  str = result;

  return result;
}