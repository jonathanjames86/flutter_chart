// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:charted_flutter/flutter.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
    title: 'Chart test',
    routes: <String, WidgetBuilder> {
      '/': (BuildContext context) => new ChartSample()
    }
  ));
}

class ChartSample extends StatefulWidget {
  @override
  State createState() => new ChartSampleState();
}

class ChartSampleState extends State<ChartSample> {
  ChartData data;
  ChartConfig chartConfig;
  CartesianChartWidget chart;
  bool get enableRemoveRow => (data.rows.length > 1);
  bool get enableAddRow => (data.rows.length < dataSource.length);
  bool get enableRemoveColumn => (data.columns.length > 1);
  bool get enableAddColumn => (data.columns.length < columnSource.length);
  Widget _buildChartControl() {
    return new Column(
        children: [
          new Row(
            children: [
              new RaisedButton(
                child: new Text('Add Row'),
                onPressed: enableAddRow ? _onAddRow : null
              ),
              new RaisedButton(
                child: new Text('Add Column'),
                onPressed: enableAddColumn ? _onAddColumn : null
              )
            ]
          ),
          new Row(
            children: [
              new RaisedButton(
                child: new Text('Remove Row'),
                onPressed: enableRemoveRow ? _onRemoveRow : null
              ),
              new RaisedButton(
                child: new Text('Remove Column'),
                onPressed: enableRemoveColumn ? _onRemoveColumn : null
              )
            ]
          ),
          new Flexible(child: chart)
        ]
      );
  }

  Widget build(BuildContext context) {
    if (data == null) {
      data = _buildChartData();
    }
    if (chartConfig == null) {
      chartConfig = _buildChartConfig();
    }
    var chartProperty = new ChartProperty(data, chartConfig, autoUpdate: true);
    chart = new CartesianChartWidget(chartProperty);
    return new Scaffold(
      appBar: new AppBar (
        title: new Text('Sample Chart')
      ),
      body: _buildChartControl()
    );
  }

  void _onAddRow() {
    setState(() {
      (data.rows as List).add(dataSource[data.rows.length]);
    });
  }

  void _onAddColumn() {
    setState(() {
      (data.columns as List).add(columnSource[data.columns.length]);
    });
  }

  void _onRemoveRow() {
    setState(() {
      (data.rows as List).removeLast();
    });
  }

  void _onRemoveColumn() {
    setState(() {
      (data.columns as List).removeLast();
    });
  }

  List dataSource = const [
      const ['January',   4.50,  7.0,  6.0],
      const ['February',  5.61, 16.0,  8.0],
      const ['March',     8.26, 36.0,  9.0],
      const ['April',    15.46, 63.0, 49.0],
      const ['May',      18.50, 77.0, 46.0],
      const ['June',     14.61, 60.0,  8.0],
      const ['July',      3.26,  9.0,  6.0],
      const ['August',    1.46,  9.0,  3.0],
      const ['September', 1.46, 13.0,  9.0],
      const ['October',   2.46, 29.0,  3.0],
      const ['November',  4.46, 33.0,  9.0],
      const ['December',  8.46, 19.0,  3.0]
  ];

  List columnSource = [
      new ChartColumnSpec(label: 'Month', type: ChartColumnSpec.TYPE_STRING),
      new ChartColumnSpec(label: 'A'),
      new ChartColumnSpec(label: 'B'),
      new ChartColumnSpec(label: 'C')];

  var initialRowCount = 4;

  ChartData _buildChartData() {
    List rows = new List.from(
        dataSource.sublist(0, initialRowCount));

    /// Sample columns used by demos with quantitative dimension scale
    List columns = new List.from(columnSource);

    return new ChartData(columns, rows);
  }

  ChartConfig _buildChartConfig() {
    var defaultSeries = new ChartSeries("Default series",
        new List.from([ 2, 3 ]), new BarChartRenderer());

    List seriesList = new List.from([ defaultSeries ]);
    return new ChartConfig(seriesList, [0]);
  }
}
