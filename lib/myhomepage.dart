import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_first_app0/pointslinechart.dart';
import 'package:noise_meter/noise_meter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const List<int> lHz = [125, 250, 500, 1000, 2000, 4000, 8000];
List<double> dbValues = List.filled(7, 0);

class _MyHomePageState extends State<MyHomePage> {
  bool isRecording = false;

  int db = 0;

  static const int levelMax = 255;
  static const int maxMicro = 90;

  static Map<int, double> mAlphaF = {
    lHz[0]: 0.349,
    lHz[1]: 0.301,
    lHz[2]: 0.267,
    lHz[3]: 0.250,
    lHz[4]: 0.249,
    lHz[5]: 0.242,
    lHz[6]: 0.254
  };

  static Map<int, double> mLU = {
    lHz[0]: -6.2,
    lHz[1]: -2.0,
    lHz[2]: 0.0,
    lHz[3]: 0.0,
    lHz[4]: -1.0,
    lHz[5]: 1.2,
    lHz[6]: -12.2
  };

  static Map<int, double> mTf = {
    lHz[0]: 22.1,
    lHz[1]: 11.4,
    lHz[2]: 4.4,
    lHz[3]: 2.4,
    lHz[4]: -1.3,
    lHz[5]: -5.4,
    lHz[6]: 12.6
  };

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

  double calculateFonValue() {
    int ghz = lHz[3];

    double fArg =
        pow((0.4 * pow(10, ((db + mLU[ghz]!) / 10) - 9)), mAlphaF[1000]!)
            .toDouble();
    double sArg =
        pow((0.4 * pow(10, ((mTf[ghz]! + mLU[ghz]!) / 10) - 9)), mAlphaF[ghz]!)
            .toDouble();

    double bf = fArg - sArg + 0.005135;
    double ln = 40 * (log(bf) / ln10) + 94;

    return ln;
  }

  void calculateDbValues(double ln) {
    for (int i = 0; i < 7; i++) {
      double af = 4.47 * pow(10, -3) * (pow(10, 0.025 * ln) - 1.15) +
          pow(0.4 * pow(10, ((mTf[lHz[i]]! + mLU[lHz[i]]!) / 10) - 9),
              mAlphaF[lHz[i]]!);

      double lp = 10 / mAlphaF[lHz[i]]! * (log(af) / ln10) - mLU[lHz[i]]! + 94;

      dbValues[i] = num.parse(lp.toStringAsFixed(2)).toDouble();
    }
  }

  Dialog outputValues() {
    double ln = calculateFonValue();
    calculateDbValues(ln);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      elevation: 16,
      child: Table(
        border: TableBorder.all(width: 1.0, color: Colors.black),
        children: [
          //lHz.length + 1,
          for (int i = 0; i < lHz.length + 1; i++)
            TableRow(
              children: [
                TableCell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      if (i == 0) const Text('Hertz'),
                      if (i == 0) const Text('DeciBel'),
                      if (i > 0) Text(lHz[i - 1].toString()),
                      if (i > 0) Text(dbValues[i - 1].toString()),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void start() async =>
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);

  void onData(NoiseReading noiseReading) {
    setState(() => db = noiseReading.maxDecibel.toInt());
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
          // Кнопка записи/паузы
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
              child: const Text(
                "Показать график",
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                calculateDbValues(calculateFonValue());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PointsLineChart(
                      seriesList: createChart(lHz: lHz, dbValues: dbValues),
                      animate: false,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 228, 129, 0),
                ),
              ),
            ),
          ),
          // Кнопка вывода значений в таблице
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              child: const Text("Показать значения"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return outputValues();
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
