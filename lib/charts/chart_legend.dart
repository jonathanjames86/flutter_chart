//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.flutter.charts;



///
/// Class representing an item in the legend.
///
class ChartLegendItem {
  /// Index of the row/column in [ChartData]. Legend uses column based coloring
  /// in [CartesianArea] that has useRowColoring set to false and row based
  /// coloring in all other cases.
  int index;

  /// HTML color used for the row/column in chart
  String color;

  /// The label of the item.
  String label;

  /// Description of the item.
  String description;

  /// Pre-formatted value to use as value.
  String value;

  /// List of series that this column is part of
  Iterable<ChartSeries> series;

  ChartLegendItem(
      {this.index,
      this.color,
      this.label,
      this.description,
      this.series,
      this.value});
}
