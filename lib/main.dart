import 'dart:async';
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

  static const int levelMax = 255;
  static const int maxMicro = 90;

  static const List<int> Hz = [125, 250, 500, 1000, 2000, 4000, 8000];
  var dbValues = List.filled(7, 0);

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

  void start() async =>
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);

  void onData(NoiseReading noiseReading) {
    setState(() {
      db = noiseReading.maxDecibel.toInt();
    });
    debugPrint(noiseReading.meanDecibel.toStringAsFixed(4));
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
    int percent = 100 * db ~/ maxMicro;
    final Color circleColor = Color.fromARGB(
      153,
      levelMax * percent ~/ 100,
      (levelMax - levelMax * percent) ~/ 100,
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
          Align(
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
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                      elevation: 16,
                      child: Table(
                        border:
                            TableBorder.all(width: 1.0, color: Colors.black),
                        children: [
                          TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    new Text('Hertz'),
                                    new Text('DeciBel'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 228, 129, 0),
                ),
              ),
            ),
            // alignment: Alignment.bottomCenter,
            // child: ElevatedButton(
            //   onPressed: outputValues,
            //   child: const Text(
            //     "Вывод значений",
            //     textAlign: TextAlign.center,
            //   ),
            //   style: ButtonStyle(
            //     backgroundColor: MaterialStateProperty.all<Color>(
            //       const Color.fromARGB(255, 228, 129, 0),
            //     ),
            //   ),
            // ),
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