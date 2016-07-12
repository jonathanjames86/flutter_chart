//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.flutter.charts;

class DefaultChartAxisImpl {
  CartesianChartRenderObject _rdrObj;
  ChartAxisConfig _config;
  ChartAxisTheme _theme;
  TextStyle _textStyle;
  AxisTicks _axisTicksPlacement;

  int _column;
  bool _isDimension;
  ChartColumnSpec _columnSpec;

  bool _isVertical;
  String _orientation;
  Scale _scale;
  Rect size;

  DefaultChartAxisImpl.withAxisConfig(this._rdrObj, this._config);
  DefaultChartAxisImpl(this._rdrObj);

  void initAxisDomain(int column, bool isDimension, Iterable domain) {
    _columnSpec = _rdrObj.property.data.columns.elementAt(column);
    _column = column;
    _isDimension = isDimension;

    // If we don't have a scale yet, create one.
    if (scale == null) {
      _scale = _columnSpec.createDefaultScale();
    }

    // We have the scale, get theme.
    _theme = isDimension
        ? _rdrObj.property.theme.getDimensionAxisTheme(scale)
        : _rdrObj.property.theme.getMeasureAxisTheme(scale);

    _textStyle = _rdrObj.property.theme.getTextTheme().axisTicksTextStyle;

    // Sets the domain if not using a custom scale.
    if (_config == null || (_config != null && _config.scale == null)) {
      scale.domain = domain;
      scale.nice = !_isDimension;
    }
  }

  void initAxisScale(Iterable range) {
    assert(scale != null);
    if (scale is OrdinalScale) {
      var usingBands = _rdrObj.dimensionsUsingBands.contains(_column),
          innerPadding = usingBands ? _theme.axisBandInnerPadding : 1.0,
          outerPadding =
          usingBands ? _theme.axisBandOuterPadding : _theme.axisOuterPadding;

      // This is because when left axis is primary the first data row should
      // appear on top of the y-axis instead of on bottom.
      if (_rdrObj.property.config.isLeftAxisPrimary) {
        range = range.toList().reversed;
      }
      (scale as OrdinalScale)
          .rangeRoundBands(range, innerPadding, outerPadding);
    } else {
      scale.range = range;
      scale.ticksCount = _theme.axisTickCount;
    }
  }

  void prepareToPaint(String orientation) {
    if (orientation == null) orientation = ORIENTATION_BOTTOM;
    _orientation = orientation;
    _isVertical =
        _orientation == ORIENTATION_LEFT || _orientation == ORIENTATION_RIGHT;

    var layout = _rdrObj.chartLayout.chartArea;
    size = _isVertical
        ? new Rect.fromLTWH(0.0, 0.0, _theme.verticalAxisWidth, layout.width)
        : new Rect.fromLTWH(0.0, 0.0, layout.height,
           _theme.horizontalAxisHeight);

    // Handle auto re-sizing of horizontal axis.
    if (_isVertical) {
      var ticks = (_config != null && !isNullOrEmpty(_config.tickValues))
              ? _config.tickValues
              : scale.ticks,
          formatter = _columnSpec.formatter == null
              ? scale.createTickFormatter()
              : _columnSpec.formatter,
          formattedTicks = ticks.map((x) => formatter(x)).toList(),
          shortenedTicks = formattedTicks;

      var width = _getLongestTextWidth(formattedTicks);
      if (_theme.verticalAxisAutoResize) {
        size = new Rect.fromLTWH(size.left, size.top, width +
            _theme.axisTickPadding * 2 + math.max(_theme.axisTickSize, 0),
            size.height);
      }
      _axisTicksPlacement =
          new PrecomputedAxisTicks(ticks, formattedTicks, shortenedTicks);
    }
  }

  double _getLongestTextWidth(List ticks) {
    var width = 0;
    for (var tick in ticks) {
      // Tick values
      TextSpan textSpan = new TextSpan(
          text: tick, style: _textStyle);
      TextPainter textPainter = new TextPainter(text: textSpan,
          textAlign: TextAlign.center)..layout();
      if (width < textPainter.width) {
        width = textPainter.width;
      }
    }
    return width;
  }

  void paint(Canvas canvas, {bool preRender: false}) {
    assert(scale != null);
    var rect = _rdrObj.chartLayout.axes[_orientation],
        renderAreaRect = _rdrObj.chartLayout.renderArea,
        range = _isVertical ? [rect.height, 0] : [0, rect.width],
        innerTickSize = _theme.axisTickSize <= ChartAxisTheme.FILL_RENDER_AREA
            ? 0 - (_isVertical ? renderAreaRect.width : renderAreaRect.height)
            : _theme.axisTickSize,
        tickValues = _config != null && !isNullOrEmpty(_config.tickValues)
            ? _config.tickValues
            : null;

    if (!_isVertical) {
      _axisTicksPlacement = new RotateHorizontalAxisTicks(
          rect, _theme.ticksFont, _theme.axisTickSize + _theme.axisTickPadding);
    }

    initAxisScale(range);
    var axis = new AxisRenderer(
        orientation: _orientation,
        innerTickSize: innerTickSize,
        outerTickSize: 0,
        tickPadding: _theme.axisTickPadding,
        tickFormat: _columnSpec.formatter,
        tickValues: tickValues,
        scale: scale,
        isLeftAxisPrimary: _rdrObj.property.config.isLeftAxisPrimary
      );

    axis.paint(canvas, rect, _textStyle, axisTicksBuilder: _axisTicksPlacement,
        isRTL: _rdrObj.property.config.isRTL);
  }

  void clear() {}

  // Scale passed through configuration takes precedence
  Scale get scale =>
      (_config != null && _config.scale != null) ? _config.scale : _scale;

  set scale(Scale value) => _scale = value;
}

class PrecomputedAxisTicks implements AxisTicks {
  final int rotation = 0;
  final Iterable ticks;
  final Iterable formattedTicks;
  final Iterable shortenedTicks;
  const PrecomputedAxisTicks(
      this.ticks, this.formattedTicks, this.shortenedTicks);
  void init(AxisRenderer axis) {}
}

class RotateHorizontalAxisTicks implements AxisTicks {
  final Rect rect;
  final String ticksFont;
  final int tickLineLength;

  int rotation = 0;
  Iterable ticks;
  Iterable formattedTicks;
  Iterable shortenedTicks;

  RotateHorizontalAxisTicks(this.rect, this.ticksFont, this.tickLineLength);

  void init(AxisRenderer axis) {
    assert(axis.orientation == ORIENTATION_BOTTOM ||
        axis.orientation == ORIENTATION_TOP);
    assert(ticksFont != null);
    ticks = axis.tickValues;
    formattedTicks = ticks.map((x) => axis.tickFormat(x)).toList();
    shortenedTicks = formattedTicks;

// TODO(midoringo): Implement rotation of tick label.
    // var range = axis.scale.rangeExtent,
    //     textMetrics = new TextMetrics(fontStyle: ticksFont),
    //     allowedWidth = (range.max - range.min) ~/ ticks.length,
    //     maxLabelWidth = textMetrics.getLongestTextWidth(formattedTicks);
    //
    // // Check if we need rotation
    // if (0.90 * allowedWidth < maxLabelWidth) {
    //   var rectHeight =
    //       tickLineLength > 0 ? rect.height - tickLineLength : rect.height;
    //   rotation = 45;
    //
    //   // Check if we have enough space to render full chart
    //   allowedWidth = (1.4142 * (rectHeight)) - (textMetrics.fontSize / 1.4142);
    //   if (maxLabelWidth > allowedWidth) {
    //     shortenedTicks = formattedTicks
    //         .map((x) => textMetrics.ellipsizeText(x, allowedWidth))
    //         .toList();
    //   }
    // }
  }
}
