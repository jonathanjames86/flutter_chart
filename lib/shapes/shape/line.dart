//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.flutter.shapes;

/// Function to convert a list of points to path.
typedef void LinePathBulider(Iterable<Point> points, Path path);

// TODO(midoringo): Keeping the typedef of SeletionValueAccessor here, we may
// or may not decided to support selection in the future.
/** Callback used to access a value from a datum */
typedef E SelectionValueAccessor<E>(datum, int index);

///
/// [SvgLine] provides a data-driven way to create path descriptions
/// that can be used to draw lines.
///
class LinePathBuilder {
  static const LINE_INTERPOLATOR_LINEAR = 'linear';

  /// Callback to access/convert datum to x coordinate value.
  final SelectionValueAccessor<num> xValueAccessor;

  /// Callback to access/convert datum to y coordinate value.
  final SelectionValueAccessor<num> yValueAccessor;

  /// Interpolator that is used for creating the path.
  final LinePathBulider builder;

  LinePathBuilder(
      {this.xValueAccessor: defaultDataToX,
      this.yValueAccessor: defaultDataToY,
      this.builder: defaultLinePathBuilder});

  // Builds the path by interpolating the lines between all points in the input.
  Path build(List<double> dataInLine) {
    Path result = new Path();
    var points = [];
    for (var i = 0; i < dataInLine.length; i++) {
      var datum = dataInLine[i];
      if (datum != null) {
        points.add(new Point(xValueAccessor(datum, i),
            yValueAccessor(datum, i)));
      } else if (points.isNotEmpty) {
        builder(points, result);
        points.clear();
      }
    }
    if (points.isNotEmpty) {
      builder(points, result);
    }
    return result;
  }

  /// Default implementation of [xValueAccessor].
  /// Returns the first element if [d] is an iterable, otherwise returns [d].
  static num defaultDataToX(d, i) => d is Iterable ? d.first : d;

  /// Default implementation of [yValueAccessor].
  /// Returns the second element if [d] is an iterable, otherwise returns [d].
  static num defaultDataToY(d, i) => d is Iterable ? d.elementAt(1) : d;

  /// Default implementation of [isDefined].
  /// Returns true for all non-null values of [d].
  static bool defaultIsDefined(d, i, e) => d != null;

  // /// Linear interpolator.
  // static String _linear(Iterable points, _) =>
  //     points.map((pt) => '${pt.x},${pt.y}').join('L');

  /// Linear interpolator.
  static void defaultLinePathBuilder(Iterable<Point> points, Path path) {
    for (var i = 0; i < points.length; i++) {
      Point point = points.elementAt(i);
      if (i == 0) {
        path.moveTo(point.x, point.y);
      } else {
        path.lineTo(point.x, point.y);
      }
    }
  }
}
