import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isRecording = false;

  int db = 0;

// Delete after release
  int rDebug = 0;
  int gDebug = 0;

  static const int levelMax = 255;
  static const int maxMicro = 90;

  static const List<int> lHz = [125, 250, 500, 1000, 2000, 4000, 8000];

  static Map<int, double> m_alpha_f = {
    lHz[0]: 0.349,
    lHz[1]: 0.301,
    lHz[2]: 0.267,
    lHz[3]: 0.250,
    lHz[4]: 0.249,
    lHz[5]: 0.242,
    lHz[6]: 0.254
  };

  static Map<int, double> mL_U = {
    lHz[0]: -6.2,
    lHz[1]: -2.0,
    lHz[2]: 0.0,
    lHz[3]: 0.0,
    lHz[4]: -1.0,
    lHz[5]: 1.2,
    lHz[6]: -12.2
  };

  static Map<int, double> mT_f = {
    lHz[0]: 22.1,
    lHz[1]: 11.4,
    lHz[2]: 4.4,
    lHz[3]: 2.4,
    lHz[4]: -1.3,
    lHz[5]: -5.4,
    lHz[6]: 12.6
  };

  // static var dbValues = List.filled(7, 0);
  static List<double> dbValues = List.filled(7, 0);

  StreamSubscription<NoiseReading>? _noiseSubscription;
  late NoiseMeter _noiseMeter;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter(onError);
  }

  void startOnPause() {
    if (isRecording) {
      stopRecorder();
      setState(() {
        isRecording = false;
      });
    } else {
      start();
      setState(() {
        isRecording = true;
      });
    }
  }

  void saveValues() {}

  double calculateFonValue() {
    int GHz = lHz[3]; // получаем дБ по умолчанию на этой частоте

    double fArg =
        pow((0.4 * pow(10, ((db + mL_U[GHz]!) / 10) - 9)), m_alpha_f[1000]!)
            .toDouble();
    double sArg = pow((0.4 * pow(10, ((mT_f[GHz]! + mL_U[GHz]!) / 10) - 9)),
            m_alpha_f[GHz]!)
        .toDouble();

    double B_f = fArg - sArg + 0.005135;

    double L_N = 40 * (log(B_f) / ln10) + 94;

    return L_N;
  }

  void calculateDbValues(double L_N) {
    for (int i = 0; i < 7; i++) {
      double A_f = 4.47 * pow(10, -3) * (pow(10, 0.025 * L_N) - 1.15) +
          pow(0.4 * pow(10, ((mT_f[lHz[i]]! + mL_U[lHz[i]]!) / 10) - 9),
              m_alpha_f[lHz[i]]!);

      double L_p =
          10 / m_alpha_f[lHz[i]]! * (log(A_f) / ln10) - mL_U[lHz[i]]! + 94;

      dbValues[i] = num.parse(L_p.toStringAsFixed(2)).toDouble();
    }
  }

  Dialog outputValues() {
    double L_N = calculateFonValue();
    calculateDbValues(L_N);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      elevation: 16,
      child: Table(
        border: TableBorder.all(width: 1.0, color: Colors.black),
        children: [
          for (int i = 0; i < 8; i++)
            TableRow(
              children: [
                TableCell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      if (i == 0) new Text('Hertz'),
                      if (i == 0) new Text('DeciBel'),
                      if (i > 0) new Text(lHz[i - 1].toString()),
                      if (i > 0) new Text(dbValues[i - 1].toString()),
                    ],
                  ),
                ),
              ],
            ),
          // В случае чего, вместо цикла вернуть закомментированное

          // TableRow(
          //   children: [
          //     TableCell(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: <Widget>[
          //           new Text(lHz[0].toString()),
          //           new Text(dbValues[0].toString()),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          // TableRow(
          //   children: [
          //     TableCell(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: <Widget>[
          //           new Text(lHz[1].toString()),
          //           new Text(dbValues[1].toString()),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          // TableRow(
          //   children: [
          //     TableCell(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: <Widget>[
          //           new Text(lHz[2].toString()),
          //           new Text(dbValues[2].toString()),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          // TableRow(
          //   children: [
          //     TableCell(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: <Widget>[
          //           new Text(lHz[3].toString()),
          //           new Text(dbValues[3].toString()),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          // TableRow(
          //   children: [
          //     TableCell(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: <Widget>[
          //           new Text(lHz[4].toString()),
          //           new Text(dbValues[4].toString()),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          // TableRow(
          //   children: [
          //     TableCell(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: <Widget>[
          //           new Text(lHz[5].toString()),
          //           new Text(dbValues[5].toString()),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          // TableRow(
          //   children: [
          //     TableCell(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: <Widget>[
          //           new Text(lHz[6].toString()),
          //           new Text(dbValues[6].toString()),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  void start() async =>
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);

  void onData(NoiseReading noiseReading) {
    setState(() {
      db = noiseReading.maxDecibel.toInt();
    });
    debugPrint(noiseReading.meanDecibel.toStringAsFixed(4) +
        ' ' +
        rDebug.toString() +
        ' ' +
        gDebug.toString());
  }

  void onError(Object error) {
    debugPrint(error.toString());
    setState(() {
      isRecording = false;
    });
  }

  void stopRecorder() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription!.cancel();
        _noiseSubscription = null;
      }
      setState(() {
        isRecording = false;
      });
    } catch (err) {
      debugPrint('stopRecorder error: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    String textDb = "$db db";

    int percent = 100 * db ~/ (maxMicro ~/ 2);

    int r_ = levelMax * percent ~/ 100;
    int g_ = 255;
    if (r_ >= 230) {
      r_ = 255;
      g_ = 2 * levelMax - levelMax * percent ~/ 100;
      if (g_ > 255) {
        g_ = 255;
      }
    }

    rDebug = r_;
    gDebug = g_;
    final Color circleColor = Color.fromARGB(
      153,
      r_,
      g_,
      0,
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 44, 32, 32),
      appBar: AppBar(
        title: const Text('Noise DB Scanner'),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(40),
            child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        textDb,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 55),
                      )),
                  width: 300.0,
                  height: 300.0,
                  decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5.0,
                          spreadRadius: 5.0,
                          offset: Offset(0, 0),
                        )
                      ]),
                )),
          ),
          SizedBox(
            width: 1000,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: startOnPause,
                child: Text(
                  isRecording ? "Остановить запись" : "Начать запись",
                  textAlign: TextAlign.center,
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 228, 129, 0),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: saveValues,
              child: const Text(
                "Сохранить значения",
                textAlign: TextAlign.center,
              ),
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
              child: Text("Output values"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return outputValues();
                    // Dialog(
                    //   shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(40)),
                    //   elevation: 16,
                    //   child: Table(
                    //     border:
                    //         TableBorder.all(width: 1.0, color: Colors.black),
                    //     children: [
                    //       TableRow(
                    //         children: [
                    //           TableCell(
                    //             child: Row(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.spaceAround,
                    //               children: <Widget>[
                    //                 new Text('Hertz'),
                    //                 new Text('DeciBel'),
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       TableRow(
                    //         children: [
                    //           TableCell(
                    //             child: Row(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.spaceAround,
                    //               children: <Widget>[
                    //                 new Text(Hz[1].toString()),
                    //                 new Text(db.toString()),
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // );
                  },
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 228, 129, 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Circle extends StatelessWidget {
  const Circle({
    Key? key,
    required this.text,
    required this.color,
  }) : super(key: key);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 55),
          )),
      width: 300.0,
      height: 300.0,
      decoration:
          BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: const [
        BoxShadow(
          color: Color.fromARGB(255, 0, 0, 0),
          blurRadius: 5.0,
          spreadRadius: 5.0,
          offset: Offset(0, 0),
        )
      ]),
    );
  }
}


 //   Container(
          //     height: MediaQuery.of(context).size.height - 530.0,
          //     child: Align(
          //         alignment: Alignment.bottomCenter,
          //         child: ElevatedButton(
          //             onPressed: startOnPause,
          //             child: Text(textScanButton),
          //             style: ,
          //   ),
          //   // Container(
          //   //   height: MediaQuery.of(context).size.height - 465.0,
          //   //   child: Align(
          //   //       alignment: Alignment.bottomCenter,
          //   //       child: ElevatedButton(
          //   //           onPressed: saveValues,
          //   //           child: Text("textButton"),
          //   //           style: ButtonStyle(
          //   //               backgroundColor: MaterialStateProperty.all<Color>(
          //   //                   Color.fromARGB(255, 14, 172, 0))))),
          //   // )

          // ElevatedButton(
// //               onPressed: startOnPause,
// //               child: Text(textScanButton),
// //               style: ButtonStyle(
// //                   backgroundColor: MaterialStateProperty.all<Color>(
// //                       Color.fromARGB(255, 228, 129, 0)))),



    // old formula
    // int percent = 100 * db ~/ maxMicro;
    // final Color circleColor = Color.fromARGB(
    //   153,
    //   levelMax * percent ~/ 100, // red
    //   (levelMax - levelMax * percent) ~/ 100, // green
    //   0,
    // );