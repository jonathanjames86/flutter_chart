part of charted.flutter.charts;

/// Renders data in a horizontal line spanning the length of a rangeband.
/// The layout is exactly like a stacked bar chart but only render the bar as a
/// line at where the top of the bar would have been.
class LineSegmentChartRenderer extends CartesianRendererBase {
  final Iterable<int> dimensionsUsingBand = const [0];
  final bool alwaysAnimate;

  @override
  final String name = "line-sgmt-rdr";

  LineSegmentChartRenderer({this.alwaysAnimate: false});

  /// Returns false if the number of dimension axes on the area is 0.
  /// Otherwise, the first dimension scale is used to render the chart.
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

    var measuresCount = series.measures.length,
        measureScale = rdrObj.measureScales(series).first,
        dimensionScale = rdrObj.dimensionScales.first;

    var rows = new List()
      ..addAll(rdrObj.property.data.rows.map((row) => new List.generate(
          measuresCount,
          (i) => row.elementAt(series.measures.elementAt(i)))));

    var dimensionVals = rdrObj.property.data.rows
        .map((row) => row.elementAt(rdrObj.property.config.dimensions.first))
        .toList();

    var strokeWidth = theme.defaultStrokeWidth,
        strokeWidthOffset = strokeWidth ~/ 2;

    var scaled0 = measureScale.scale(0.0);
    var getLinePos = (d) {
      var scaledVal = measureScale.scale(d);
      return (d >= 0 ? scaledVal : scaled0) + strokeWidthOffset;
    };

    bool isLeftAxisPrimary = rdrObj.property.config.isLeftAxisPrimary;
    var yOffset = 0.0;
    // Record the groups of bars.
    for (var i = 0; i < rows.length; i++) {
      var row = rows[i];
      var xOffset = dimensionScale.scale(dimensionVals[i]);
      canvas.save();
      canvas.translate(isLeftAxisPrimary ? yOffset : xOffset,
          isLeftAxisPrimary ? xOffset : yOffset);
      for (var j = 0; j < row.length; j++) {
        Point p1, p2;
        var measurePosition = getLinePos(row[j]);
        p1 = new Point(isLeftAxisPrimary ? measurePosition : 0.0,
            isLeftAxisPrimary ? 0.0 : measurePosition);
        var barLength =
            (dimensionScale.rangeBand - strokeWidthOffset).toDouble();
        p2 = new Point(isLeftAxisPrimary ? measurePosition : barLength,
            isLeftAxisPrimary ? barLength : measurePosition);
        var measure = series.measures.elementAt(j),
            color = colorForValue(measure, j),
            paint = new Paint()
                ..strokeWidth = theme.defaultStrokeWidth
                ..color = new Color(color);
        canvas.drawLine(p1, p2, paint);
      }
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  double get bandInnerPadding =>
      theme.getDimensionAxisTheme().axisBandInnerPadding;

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void handleStateChanges() {
    // TODO: implement handleStateChanges
  }
}
