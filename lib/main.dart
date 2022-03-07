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
        theme:
            ThemeData(primarySwatch: Colors.grey, brightness: Brightness.dark),
        home: const MyHomePage(title: 'noise DB scan'),
        debugShowCheckedModeBanner: false);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isRecording = false;
  String textDb = "0 db";
  String textScanButton = "Начать сканирование";

  int dB = 0;

  int r = 255;
  int g = 255;
  final int k = 90;

  //////////////////////
  bool deleteThisBoolean = true;
  //////////////////////

  int r_ = 0;
  int g_ = 255;

  // String textButton1 = "Check";
  // dynamic arr = [0, 0, 0, 0.0];
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
        textScanButton = "Продолжить сканирование";

        isRecording = false;
      });
    } else {
      start();
      setState(() {
        textScanButton = "Прекратить сканирование";

        isRecording = true;
      });
    }
  }

  void saveValues() {}

  void start() async =>
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);

  void onData(NoiseReading noiseReading) {
    setState(() {
      dB = noiseReading.maxDecibel.toInt();

      int percent = (100 * dB / k).toInt();

      r_ = (r * percent / 100).toInt();
      g_ = (g - g * percent / 100).toInt();

      textDb = noiseReading.meanDecibel.toStringAsFixed(4) + " db";
    });
    debugPrint("NNN: " + textDb);
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
// // Widget build(BuildContext context) {
// //     Scaffold(
// //         backgroundColor: Color.fromARGB(255, 77, 77, 77),
// //         appBar: AppBar(
// //           title: Text(widget.title),
// //           foregroundColor: Color.fromARGB(255, 255, 255, 255),
// //         ));
// //     return Center(
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.all(40),
// //             child: Align(
// //                 alignment: Alignment.topCenter,
// //                 child: Circle(
// //                   text: textDb,
// //                   r: r_,
// //                   g: g_,
// //                 )),
// //           ),
// //           ElevatedButton(
// //               onPressed: startOnPause,
// //               child: Text(textScanButton),
// //               style: ButtonStyle(
// //                   backgroundColor: MaterialStateProperty.all<Color>(
// //                       Color.fromARGB(255, 228, 129, 0)))),
// //         ],
// //       ),
// //     );
// //   }
// // }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 77, 77, 77),
        appBar: AppBar(
          title: Text(widget.title),
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
        ),
        // body: Builder(builder: (BuildContext context) {
        //   return TextButton(
        //       onPressed: startOnPause,
        //       child: Text(textScanButton),
        //       // style: ButtonStyle(
        //       //     backgroundColor: MaterialStateProperty.all<Color>(
        //       //         Color.fromARGB(255, 228, 129, 0))),
        //       style: ButtonStyle(
        //           backgroundColor: MaterialStateProperty.all<Color>(
        //               Color.fromARGB(255, 255, 153, 0)),
        //           foregroundColor: MaterialStateProperty.all<Color>(
        //               Color.fromARGB(255, 0, 0, 0))));
        // }),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(40),
            child: Align(
              alignment: Alignment.topCenter,
              child: Circle(
                text: textDb,
                r: r_,
                g: g_,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 480,
            width: MediaQuery.of(context).size.width / 2,
            child: Expanded(
              child: ElevatedButton(
                onPressed: startOnPause,
                child: Text(
                  textScanButton,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          //   Container(
          //     height: MediaQuery.of(context).size.height - 530.0,
          //     child: Align(
          //         alignment: Alignment.bottomCenter,
          //         child: ElevatedButton(
          //             onPressed: startOnPause,
          //             child: Text(textScanButton),
          //             style: ButtonStyle(
          //                 backgroundColor: MaterialStateProperty.all<Color>(
          //                     Color.fromARGB(255, 228, 129, 0))))),
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
        ]));
  }
}

class Circle extends StatelessWidget {
  const Circle({Key? key, required this.text, required this.r, required this.g})
      : super(key: key);

  final String text;
  final int r;
  final int g;

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
      decoration: BoxDecoration(
          color: Color.fromARGB(153, r, g, 0),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              spreadRadius: 5.0,
              offset: Offset(0, 0),
            )
          ]),
    );
  }
}
