// !!! ГРАФИК СТРОИТСЯ ТОЛЬКО ПОСЛЕ ВЫВОДА ЗНАЧЕНИЙ В ТАБЛИЦУ
// !!! ПЕРЕДЕЛАТЬ РАСЧЕТЫ

// Выбрать шаг делений на графике

import 'package:flutter/material.dart';
import 'package:flutter_first_app0/myhomepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.grey,
          brightness: Brightness.dark,
        ),
        home: const MyHomePage(),
        debugShowCheckedModeBanner: false);
  }
}
