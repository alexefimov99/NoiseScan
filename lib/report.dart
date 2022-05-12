import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_first_app0/myhomepage.dart';

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
            outputReport(lmResult),//'\n' + lmResult.join('\n\n'),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: TextStyle(color: Color.fromARGB(255, 213, 138, 0),
                fontSize: 20,
                decoration: TextDecoration.none,
            )
          )
        ),
        ////////////////////////////////////////////
        /// Кнопка для выгрузки значений
        Align(
            alignment: Alignment.bottomCenter,
            //// Comment ID: 1
            // child: new RaisedButton(
            //   onPressed: () => saveReport('alex.efimov99@yandex.ru', 'Flutter Email Test', 'Hello Flutter'),
            //   child: new Text('Send mail'),
            //   ),

            // Comment ID: 2
            child: ElevatedButton(
              child: const Text("Сохранить отчёт"),
              onPressed: saveReport,
              // onPressed: () {
              //   showDialog(
              //     context: context,
              //     builder: (context) {
              //       // return saveReport();
              //     },
              //   );
              // },
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

  //// Comment ID: 1
  // saveReport(String toMailId, String subject, String body) async
  // {
  //   var url = 'mailto:$toMailId?subject=$subject&body=$body';
    
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
}

String outputReport(List<Map<int, double> > lValues)
{
  // permi;
  String result = '\n';

  for(int i = 0; i < lValues.length; i++)
  {
    result += lValues[i].toString() + '\n\n';
    
    // final splitted = result.split(', ');
    // При необходимости разбить строки, чтобы каждая герцовка 
    // была на новой строке (тогда надо настроить скроллинг страницы, 
    // иначе не будет хватать места на экране, либо придумать что-нибудь еще)
  }

  result = result.replaceAll('{', '');
  result = result.replaceAll('}', '');

  str = result;

  return result;
}

// Comment ID: 2
void saveReport() async
{
  var res = await Permission.manageExternalStorage.status;
  if(res.isDenied)
  {
    print('1');
  }
  if(res.isGranted)
  {
    print('2');
  }
  if(res.isLimited)
  {
    print('3');
  }
  if(res.isPermanentlyDenied)
  {
    print('4');
  }
  if(res.isRestricted)
  {
    print('5');
  }

  if(await Permission.manageExternalStorage.request().isGranted)
  {
    print('6');
  }

  var dir = await getExternalStorageDirectory();
  print('dir: ${dir?.path}');

  String fileName = 'Report.txt';
  String saveFolder = 'documents';

  var result = Permission.storage.status;
  print('Result: ${result.isDenied == true} | ${result.isGranted == true} | ${result.isLimited == true} |' +
   '${result.isPermanentlyDenied == true} | ${result.isRestricted == true}');
  if(dir != null)
  {
    dir = dir.parent.parent.parent.parent;
    print('dir another: ${dir.path}');

    if(await Directory(dir.path + '/$saveFolder').exists())
    {
      print('documents is exists');

      dir = Directory('${dir.path}/$saveFolder');
      print('dir path: ${dir.path}');

      var file = File('${dir.path}/${fileName}');
      print(file.path);
      file.writeAsString('str');

    }
    else
    {
      print('nothing exists');
    }
  }


  // await file.writeAsString(str);

  // var dir = Directory.fromUri(Uri.directory('UNO\\DUE\\'));
  // dir.createSync(recursive: true);

  // var file = File('${dir.absolute.path}\demo.txt');
  // file.writeAsStringSync('ABCDEFHJ');
}

