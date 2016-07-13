//
// Copyright 2016 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.flutter.charts;

// Contains the all the settings including data and config for the chart.
class ChartProperty {

  /// Data used by the chart. Chart isn't updated till the next call to
  /// draw function if [autoUpdate] is set to false.
  ///
  /// Setting new value to [data] will update chart if [autoUpdate] is set.
  ChartData data;

  /// Configuration for this chart.  [ChartArea] subscribes to changes on
  /// [config] and calls draw upon any changes.
  ///
  /// Refer to [ChartConfig] for further documentation about which changes
  /// are added to the stream, which in turn trigger an update on the chart.
  ChartConfig config;

  /// Theme for this chart. Any changes to [theme] are not applied to the chart
  /// until it is redrawn. Changes can be forced by calling [draw] function.
  ChartTheme theme;

  /// When set to true, [ChartArea] subscribes to changes on data and updates
  /// the chart when [data] or [config] changes. Defaults to false.
  final bool autoUpdate;

  /// When true, [ChartArea] and renderers that support coloring by row,
  /// use row indices and values to color the chart. Defaults to false.
  final bool useRowColoring;

  final bool useTwoDimensionAxes;

  ChartProperty(
      this.data,
      this.config,
      {this.autoUpdate: false,
      this.useTwoDimensionAxes: false,
      this.useRowColoring: false,
      this.theme}) {
        if (theme == null) {
          theme = new QuantumChartTheme();
        }
        // data.addListener(notifyPropertyChange);
        // config.addListener(notifyPropertyChange);
  }
}
