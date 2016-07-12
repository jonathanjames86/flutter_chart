//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.flutter.charts;

// TODO(midoringo): Handle click/hover/selection event, show tracking circle.
class LineChartRenderer extends CartesianRendererBase {
  final Iterable<int> dimensionsUsingBand = const [];
  final bool alwaysAnimate;
  final bool trackDataPoints;
  final bool trackOnDimensionAxis;
  final int quantitativeScaleProximity;
  int currentDataIndex = -1;

  @override
  final String name = "line-rdr";

  LineChartRenderer(
      {this.alwaysAnimate: false,
      this.trackDataPoints: true,
      this.trackOnDimensionAxis: false,
      this.quantitativeScaleProximity: 5});

  // Returns false if the number of dimension axes on the area is 0.
  // Otherwise, the first dimension scale is used to render the chart.
  @override
  bool prepare(CartesianChartRenderObject rdrObj, ChartSeries series) {
    _ensureAreaAndSeries(rdrObj, series);
    // TODO(midoringo): Add base class ChartRenderObject, and this following
    // check would be more valid.
    return rdrObj is CartesianChartRenderObject;
  }

  @override
  void paint(Canvas canvas, Rect rect) {
    _ensureReadyToDraw();
    canvas.save();
    canvas.translate(rect.left, rect.top);
    Scale measureScale = rdrObj.measureScales(series).first,
        dimensionScale = rdrObj.dimensionScales.first;

    // Create lists of values in measure columns.
    List lines = series.measures.map((column) {
      return rdrObj.property.data.rows.map((values) => values[column]).toList();
    }).toList();

    // We only support one dimension axes, so we always use the
    // first dimension.
    List x = rdrObj.property.data.rows
        .map((row) => row.elementAt(rdrObj.property.config.dimensions.first))
        .toList();

    var rangeBandOffset =
        dimensionScale is OrdinalScale ? dimensionScale.rangeBand / 2 : 0.0;

    var dimensionValueAccessor =
        (d, i) => dimensionScale.scale(x[i]) + rangeBandOffset;
    var measureValueAccessor = (d, i) => measureScale.scale(d);

    var lineBuilder = new LinePathBuilder(
        xValueAccessor: !rdrObj.property.config.isLeftAxisPrimary
            ? dimensionValueAccessor : measureValueAccessor,
        yValueAccessor: !rdrObj.property.config.isLeftAxisPrimary
            ? measureValueAccessor : dimensionValueAccessor);

    for (var i = 0; i < lines.length; i++) {
      var column = series.measures.elementAt(i),
          color = colorForColumn(column);

      var paint = new Paint()
          ..strokeWidth = theme.defaultStrokeWidth
          ..style = PaintingStyle.stroke
          ..color = new Color(color);
      canvas.drawPath(lineBuilder.build(lines[i]), paint);
    }
    canvas.restore();
  }

  // TODO(midoringo): handle state change.
  @override
  void handleStateChanges() {}

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
