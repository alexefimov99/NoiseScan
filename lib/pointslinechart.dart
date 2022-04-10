import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_first_app0/linear_series.dart';
import 'package:flutter_first_app0/myhomepage.dart';

import 'dart:math';

class PointsLineChart extends StatelessWidget {
  final List<Series<dynamic, num>> seriesList;
  final bool animate;

  const PointsLineChart(
      {required this.seriesList, required this.animate, Key? key})
      : super(key: key);

  factory PointsLineChart.withSampleData() {
    return PointsLineChart(
      seriesList: createChart(lHz: lHz, dbValues: dbValues),
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(seriesList,
        primaryMeasureAxis: new NumericAxisSpec(
            tickProviderSpec:
                new BasicNumericTickProviderSpec(zeroBound: false)),
        animate: animate,
        defaultRenderer: LineRendererConfig(includePoints: true));
  }
}

List<Series<LinearSeries, num>> createChart({required lHz, required dbValues}) {
  final data = [
    for (int i = 0; i < lHz.length; i++) LinearSeries(lHz[i], dbValues[i])
  ];

  int min = 0;
  int max = 0;

  for (int i = 0; i < 7; i++) {
    if (dbValues[i].toInt() > max) {
      max = dbValues[i].toInt();
      max ~/= 10;
      max *= 10 + 10;
    }
    if (dbValues[i].toInt() < min) {
      min = dbValues[i].toInt();
      min ~/= 10;
      min *= 10 + 10;
    }
  }

  return [
    Series<LinearSeries, num>(
      id: 'Sound',
      data: data,
      domainFn: (LinearSeries noise, int? int) => noise.lsHz,
      measureFn: (LinearSeries noise, int? double) => noise.lsDb,
    )
  ];
}
