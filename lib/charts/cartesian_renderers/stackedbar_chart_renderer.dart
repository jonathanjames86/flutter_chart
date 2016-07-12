//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.flutter.charts;

class StackedBarChartRenderer extends CartesianRendererBase {
  static const RADIUS = 2.0;

  final Iterable<int> dimensionsUsingBand = const [0];
  final bool alwaysAnimate;

  @override
  final String name = "stack-rdr";

  /// Used to capture the last measure with data in a data row.  This is used
  /// to decided whether to round the cornor of the bar or not.
  List<int> _lastMeasureWithData = [];

  StackedBarChartRenderer({this.alwaysAnimate: false});

  /// Returns false if the number of dimension axes on the area is 0.
  /// Otherwise, the first dimension scale is used to render the chart.
  @override
  bool prepare(CartesianChartRenderObject rdrObj, ChartSeries series) {
    _ensureAreaAndSeries(rdrObj, series);
    return true;
  }

  @override
  void paint(Canvas canvas, Rect rect) {
    _ensureReadyToDraw();
    canvas.save();
    canvas.translate(rect.left, rect.top);
    var verticalBars = !rdrObj.property.config.isLeftAxisPrimary;

    var measuresCount = series.measures.length,
        measureScale = rdrObj.measureScales(series).first,
        dimensionScale = rdrObj.dimensionScales.first;

    var rows = new List()
      ..addAll(rdrObj.property.data.rows.map((e) => new List.generate(measuresCount,
          (i) => e.elementAt(series.measures.elementAt(_reverseIdx(i))))));

    var dimensionVals = rdrObj.property.data.rows
        .map((row) => row.elementAt(rdrObj.property.config.dimensions.first))
        .toList();

    var prevOffsetVal = new List();

    var barWidth = dimensionScale.rangeBand - theme.defaultStrokeWidth;

    // Calculate height of each segment in the bar.
    // Uses prevAllZeroHeight and prevOffset to track previous segments
    var prevAllZeroHeight = true, prevOffset = 0.0;
    var getBarLength = (d, i) {
      if (!verticalBars) return measureScale.scale(d);
      var retval = rect.height - measureScale.scale(d);
      if (i != 0) {
        // If previous bars has 0 height, don't offset for spacing
        // If any of the previous bar has non 0 height, do the offset.
        retval -= prevAllZeroHeight
            ? 1.0
            : theme.defaultSeparatorWidth;
        retval += prevOffset;
      } else {
        // When rendering next group of bars, reset prevZeroHeight.
        prevOffset = 0.0;
        prevAllZeroHeight = true;
        retval -= 1.0; // -1 so bar does not overlap x axis.
      }

      if (retval <= 0.0) {
        prevOffset = prevAllZeroHeight
            ? 0.0
            : theme.defaultSeparatorWidth + retval;
        retval = 0.0;
      }
      prevAllZeroHeight = (retval == 0) && prevAllZeroHeight;
      return retval;
    };

    // Initial "y" position of a bar that is being created.
    // Only used when animateBarGroups is set to true.
    var ic = 10000000, order = 0;
    var getInitialBarPos = (i) {
      var tempY;
      if (i <= ic && i > 0) {
        tempY = prevOffsetVal[order];
        order++;
      } else {
        tempY = verticalBars ? rect.height : 0.0;
      }
      ic = i;
      return tempY;
    };

    // Position of a bar in the stack. yPos is used to keep track of the
    // offset based on previous calls to getBarY
    var yPos = 0.0;
    var getBarPos = (d, i) {
      if (verticalBars) {
        if (i == 0) {
          yPos = measureScale.scale(0);
        }
        return yPos -= (rect.height - measureScale.scale(d));
      } else {
        if (i == 0) {
          // 1 to not overlap the axis line.
          yPos = 1.0;
        }
        var pos = yPos;
        yPos += measureScale.scale(d);
        // Check if after adding the height of the bar, if y has changed, if
        // changed, we offset for space between the bars.
        if (yPos != pos) {
          yPos += theme.defaultSeparatorWidth;
        }
        return pos;
      }
    };

    var buildPath = (d, int i, bool animate, int roundIdx) {
      var position = animate ? getInitialBarPos(i) : getBarPos(d, i),
          length = animate ? 0.0 : getBarLength(d, i),
          radius = series.measures.elementAt(_reverseIdx(i)) == roundIdx
              ? RADIUS : 0.0,
          path = (length != 0)
              ? verticalBars
                  ? topRoundedRect(0.0, position, barWidth, length, radius)
                  : rightRoundedRect(position, 0.0, length, barWidth, radius)
              : new Path();
      return path;
    };

    // Record the groups of bars.
    var pathGroups = [];
    for (var i = 0; i < rows.length; i++) {
      var paths = [];
      var roundIndex = _lastMeasureWithData[i];
      var row = rows[i];
      for (var j = 0; j < row.length; j++) {
        paths.add(buildPath(row[j] == null ? 0.0 : row[j], j,
            false, roundIndex));
      }
      pathGroups.add(paths);
    }

    // Draw the bars, the whole group needs to be offsetted by the render rect's
    // left and top, then each bar group needs to be offsetted by
    // dimensionScale.scale(dimensionVals[i]).
    for (var i = 0; i < pathGroups.length; i++) {
      canvas.save();
      canvas.translate(
        verticalBars ? dimensionScale.scale(dimensionVals[i]) : 0.0,
        verticalBars ? 0.0 : dimensionScale.scale(dimensionVals[i]));
      var paths = pathGroups[i];
      for (var j = 0; j < paths.length; j++) {
        var measure = series.measures.elementAt(_reverseIdx(j)),
            color = colorForValue(measure, _reverseIdx(j)),
            paint = new Paint()
                ..strokeWidth = theme.defaultStrokeWidth
                ..color = new Color(color);
        canvas.drawPath(paths[j], paint);
      }
      canvas.restore();
    }

    canvas.restore();
  }


  @override
  void dispose() {
  }

  @override
  double get bandInnerPadding =>
      rdrObj.property.theme.getDimensionAxisTheme().axisBandInnerPadding;

  @override
  Extent get extent {
    assert(rdrObj != null && series != null);
    var rows = rdrObj.property.data.rows,
        max = SMALL_INT_MIN,
        min = SMALL_INT_MAX,
        rowIndex = 0;
    _lastMeasureWithData = new List.generate(rows.length, (i) => -1);

    rows.forEach((row) {
      var bar = null;
      series.measures.forEach((idx) {
        var value = row.elementAt(idx);
        if (value != null && value.isFinite) {
          if (bar == null) bar = 0;
          bar += value;
          if (value.round() != 0 && _lastMeasureWithData[rowIndex] == -1) {
            _lastMeasureWithData[rowIndex] = idx;
          }
        }
      });
      if (bar > max) max = bar;
      if (bar < min) min = bar;
      rowIndex++;
    });

    return new Extent(min, max);
  }

  // TODO(midoringo): Handle State change.
  @override
  void handleStateChanges() {}

  // Stacked bar chart renders items from bottom to top (first measure is at
  // the bottom of the stack). We use [_reversedIdx] instead of index to
  // match the color and order of what is displayed in the legend.
  int _reverseIdx(int index) => series.measures.length - 1 - index;
}
