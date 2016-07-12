//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.flutter.charts;

// TODO(midoringo): handle state change, add animation.
class BarChartRenderer extends CartesianRendererBase {
  static const RADIUS = 2.0;

  final Iterable<int> dimensionsUsingBand = const [0];
  final bool alwaysAnimate;

  @override
  final String name = "bar-rdr";

  BarChartRenderer({this.alwaysAnimate: false});

  /// Returns false if the number of dimension axes on the area is 0.
  /// Otherwise, the first dimension scale is used to render the chart.
  @override
  bool prepare(CartesianChartRenderObject rdrObj, ChartSeries series) {
    _ensureAreaAndSeries(rdrObj, series);
    // TODO(midoringo): Add base class ChartRenderObject, and this following
    // check would be more valid.
    return rdrObj is CartesianChartRenderObject;
  }

  // The rect here is the full dimension to paint the chart content, excluding
  // any space reserved for axis and labels.
  void paint(Canvas canvas, Rect rect) {
    _ensureReadyToDraw();
    canvas.save();
    canvas.translate(rect.left, rect.top);
    var verticalBars = !rdrObj.property.config.isLeftAxisPrimary;

    var measuresCount = series.measures.length,
        measureScale = rdrObj.measureScales(series).first,
        dimensionScale = rdrObj.dimensionScales.first;

    var rows = new List()
      ..addAll(rdrObj.property.data.rows.map((e) => new List.generate(
          measuresCount, (i) => e[series.measures.elementAt(i)])));

    var dimensionVals = rdrObj.property.data.rows
        .map((row) => row.elementAt(rdrObj.property.config.dimensions.first))
        .toList();

    var bars = new OrdinalScale()
      ..domain = new Range(series.measures.length).toList()
      ..rangeRoundBands([0, dimensionScale.rangeBand]);

    var barWidth = bars.rangeBand.abs() -
            theme.defaultSeparatorWidth -
            theme.defaultStrokeWidth,
        strokeWidth = theme.defaultStrokeWidth,
        strokeWidthOffset = strokeWidth / 2;

    // Create and update the bars
    var scaled0 = measureScale.scale(0);
    var getBarLength = (d) {
      var scaledVal = measureScale.scale(d),
          ht = verticalBars
              ? (d >= 0 ? scaled0 - scaledVal : scaledVal - scaled0)
              : (d >= 0 ? scaledVal - scaled0 : scaled0 - scaledVal);
      ht = ht - strokeWidth;

      // If bar would be scaled to 0 height but data is not 0, render bar
      // at 1 pixel so user can see and hover over to see the data.
      return (ht < 0) ? 1.0 : ht;
    };
    var getBarPos = (d) {
      var scaledVal = measureScale.scale(d).round();

      // If bar would be scaled to 0 height but data is not 0, reserve 1 pixel
      // height plus strokeWidthOffset to position the bar.
      if (scaledVal == scaled0) {
        return verticalBars
            ? d > 0
                ? scaled0 - 1 - strokeWidthOffset
                : scaled0 + strokeWidthOffset
            : d > 0
                ? scaled0 + strokeWidthOffset
                : scaled0 - 1 - strokeWidthOffset;
      }
      return verticalBars
          ? (d >= 0 ? scaledVal : scaled0) + strokeWidthOffset
          : (d >= 0 ? scaled0 : scaledVal) + strokeWidthOffset;
    };

    var buildPath = (d, int i, bool animate) {
      // If data is null or 0, an empty path for the bar is returned directly.
      if (d == null || d == 0) return '';
      if (verticalBars) {
        var fn = d > 0 ? topRoundedRect : bottomRoundedRect;

        return fn(
            bars.scale(i) + strokeWidthOffset,
            animate ? rect.height : getBarPos(d),
            barWidth,
            animate ? 0.0 : getBarLength(d),
            RADIUS);
      } else {
        var fn = d > 0 ? rightRoundedRect : leftRoundedRect;
        return fn(getBarPos(d), bars.scale(i).toInt() + strokeWidthOffset,
            animate ? 0.0 : getBarLength(d), barWidth, RADIUS);
      }
    };

    // Record the groups of bars.
    var pathGroups = [];
    for (var i = 0; i < rows.length; i++) {
      var paths = [];
      var row = rows[i];
      for (var j = 0; j < row.length; j++) {
        paths.add(buildPath(row[j], j, false));
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
        var measure = series.measures.elementAt(j),
            color = colorForValue(measure, j),
            paint = new Paint()
                ..strokeWidth = strokeWidth
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
  double get bandInnerPadding {
    assert(series != null && rdrObj.property != null);
    var measuresCount = series.measures.length;
    return measuresCount > 2
        ? 1 - (measuresCount / (measuresCount + 1))
        : rdrObj.property.theme.getDimensionAxisTheme().axisBandInnerPadding;
  }

  @override
  double get bandOuterPadding {
    assert(series != null && rdrObj.property != null);
    return rdrObj.property.theme.getDimensionAxisTheme().axisBandOuterPadding;
  }

  // TODO (midoringo): Handle state change.
  @override
  void handleStateChanges() {}
}
