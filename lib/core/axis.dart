library charted.core.axis;

import 'dart:math' as math;

import 'package:charted_flutter/core/scales.dart';
import 'package:charted_flutter/core/utils.dart';

import 'package:flutter/material.dart';

class AxisRenderer {
  /// Orientation of the axis. Defaults to [ORIENTATION_BOTTOM].
  final String orientation;

  /// Scale used on this axis
  final Scale scale;

  /// Size of all inner ticks
  final num innerTickSize;

  /// Size of the outer two ticks
  final num outerTickSize;

  /// Padding on the ticks
  final num tickPadding;

  // Is left axis the primary axis.
  final bool isLeftAxisPrimary;

  /// List of values to be used on the ticks
  List _tickValues;

  /// Formatter for the tick labels
  FormatFunction _tickFormat;

  AxisRenderer(
      {this.orientation: ORIENTATION_BOTTOM,
      this.innerTickSize: 6,
      this.outerTickSize: 6,
      this.tickPadding: 3,
      Iterable tickValues,
      FormatFunction tickFormat,
      Scale scale,
      this.isLeftAxisPrimary: false})
      : scale = scale == null ? new LinearScale() : scale {
    _tickFormat =
        tickFormat == null ? this.scale.createTickFormatter() : tickFormat;
    _tickValues = isNullOrEmpty(tickValues) ? this.scale.ticks : tickValues;
  }

  Iterable get tickValues => _tickValues;

  FormatFunction get tickFormat => _tickFormat;

  paint(Canvas canvas, Rect rect, TextStyle textStyle,
      {AxisTicks axisTicksBuilder, bool isRTL: false}) {
    // TODO(midoringo): revisit to add animation to axis.
    var isLeft = orientation == ORIENTATION_LEFT,
        isRight = !isLeft && orientation == ORIENTATION_RIGHT,
        isVertical = isLeft || isRight,
        isBottom = !isVertical && orientation == ORIENTATION_BOTTOM,
        isTop = !(isVertical || isBottom) && orientation == ORIENTATION_TOP,
        isHorizontal = !isVertical;

    if (axisTicksBuilder == null) {
      axisTicksBuilder = new AxisTicks();
    }
    axisTicksBuilder.init(this);

    // TODO (midoringo) formatted used for hover tooltip when text is rotated
    // and ellipsed, make use of the unused variables here.
    var values = axisTicksBuilder.ticks,
        ellipsized = axisTicksBuilder.shortenedTicks,
        sign = isTop || isLeft ? -1 : 1;

    // TODO(Midoringo): This needs to be defined in the ChartAxisTheme instead.
    var paint = new Paint()
      ..strokeWidth = 2.0
      ..color = const Color(0xFF000000);
    var gridPaint = new Paint()
      ..strokeWidth = 1.0
      ..color = const Color(0x88CCCCCC);

    // Draw the axis base on orientation, y axis is not drawn.
    switch(orientation) {
      case ORIENTATION_TOP:
        if(!isLeftAxisPrimary) {
          canvas.drawLine(rect.bottomLeft, rect.bottomRight, paint);
        }
        break;
      case ORIENTATION_BOTTOM:
        if(!isLeftAxisPrimary) {
          canvas.drawLine(rect.topLeft, rect.topRight, paint);
        }
        break;
      case ORIENTATION_LEFT:
        if(isLeftAxisPrimary) {
          canvas.drawLine(rect.topLeft, rect.bottomLeft, paint);
        }
        break;
      default:
        break;
    }

    // Draw ticks, line, and text.
    for (var i = 0; i < values.length; i++) {
      var value = values.elementAt(i);
      if (isHorizontal) {

        // Tick values
        TextSpan textSpan = new TextSpan(
          text: ellipsized.elementAt(i),
          style: textStyle);
        TextPainter textPainter = new TextPainter(text: textSpan,
            textAlign: TextAlign.center)..layout();

        // Compute the offset for the ticks on the scale plus the offset of
        // the axis' render rect.
        var offsetX = scale.scale(value) + (scale is OrdinalScale ?
            (scale as OrdinalScale).rangeBand / 2 : 0.0) -
            textPainter.width / 2;
        var offsetY = sign * (math.max(innerTickSize, 0) + tickPadding);
        Offset offset = new Offset(offsetX.toDouble() + rect.left,
            offsetY.toDouble() + rect.top);
        textPainter.paint(canvas, offset);

        // Paint the horizontal axis.
        var height = sign * innerTickSize;
        var x = scale.scale(value);
        if (height != 0) {
          canvas.drawLine(new Point(rect.left + x, rect.top),
              new Point(rect.left + x, rect.top + height), gridPaint);
        }
        // TODO(midoringo): handle text rotation.
      } else {
        // Paint the vertical axis ticks.
        TextSpan textSpan = new TextSpan(
          text: ellipsized.elementAt(i),
          style: textStyle);
        TextPainter textPainter = new TextPainter(text: textSpan,
          textAlign: TextAlign.center)..layout();

        // Compute the offset for the ticks on the scale plus the offset of
        // the axis' render rect.
        var offsetX = sign * (textPainter.width + tickPadding);
        var offsetY = scale.scale(value) + (scale is OrdinalScale ?
            (scale as OrdinalScale).rangeBand / 2 : 0.0) -
            textPainter.height / 2;

        Offset offset = new Offset(offsetX.toDouble() + rect.left,
            offsetY.toDouble() + rect.top);
        textPainter.paint(canvas, offset);

        // Paint the grid lines.
        var y = scale.scale(value);
        var width = sign * innerTickSize;
        canvas.drawLine(new Point(rect.left, y),
            new Point(rect.left + width, y), gridPaint);
      }
    }
  }
}

/// Interface and the default implementation of [AxisTicks].
/// AxisTicks provides strategy to handle overlapping ticks on an
/// axis.  Default implementation assumes that the ticks don't overlap.
class AxisTicks {
  int _rotation = 0;
  Iterable _ticks;
  Iterable _formattedTicks;

  void init(AxisRenderer axis) {
    _ticks = axis.tickValues;
    _formattedTicks = _ticks.map((x) => axis.tickFormat(x));
  }

  /// When non-zero, indicates the angle by which each tick value must be
  /// rotated to avoid the overlap.
  int get rotation => _rotation;

  /// List of ticks that will be displayed on the axis.
  Iterable get ticks => _ticks;

  /// List of formatted ticks values.
  Iterable get formattedTicks => _formattedTicks;

  /// List of clipped tick values, if they had to be clipped. Must be same
  /// as the [formattedTicks] if none of the ticks were ellipsized.
  Iterable get shortenedTicks => _formattedTicks;
}
