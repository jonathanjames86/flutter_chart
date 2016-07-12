/*
 * Copyright 2014 Google Inc. All rights reserved.
 *
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file or at
 * https://developers.google.com/open-source/licenses/bsd
 */

part of charted.flutter.charts;

class QuantumChartTheme extends ChartTheme {
  static const List OTHER_COLORS = const [0xFFEEEEEE, 0xFFBDBDBD, 0xFF9E9E9E];
  static const List<List<int>> COLORS = const [
    const [0xFFC5D9FB, 0xFF4184F3, 0xFF2955C5],
    const [0xFFF3C6C2, 0xFFDB4437, 0xFFA52714],
    const [0xFFFBE7B1, 0xFFF4B400, 0xFFEF9200],
    const [0xFFB6E0CC, 0xFF0F9D58, 0xFF0A7F42],
    const [0xFFE0BDE6, 0xFFAA46BB, 0xFF691A99],
    const [0xFFB1EAF1, 0xFF00ABC0, 0xFF00828E],
    const [0xFFFFCBBB, 0xFFFF6F42, 0xFFE54918],
    const [0xFFEFF3C2, 0xFF9D9C23, 0xFF817616],
    const [0xFFC4C9E8, 0xFF5B6ABF, 0xFF3848AA],
    const [0xFFF7BACF, 0xFFEF6191, 0xFFE81D62],
    const [0xFFB1DEDA, 0xFF00786A, 0xFF004C3F],
    const [0xFFF38EB0, 0xFFC1175A, 0xFF870D4E],
  ];

  static const List<List<int>> COLORS_ASSIST = const [
    const [0xFFC5D9FB, 0xFF4184F3, 0xFF2955C5],
    const [0xFFF3C6C2, 0xFFDB4437, 0xFFA52714],
    const [0xFFFBE7B1, 0xFFF4B400, 0xFFEF9200],
    const [0xFFB6E0CC, 0xFF0F9D58, 0xFF0A7F42],
    const [0xFFE0BDE6, 0xFFAA46BB, 0xFF691A99],
    const [0xFFB1EAF1, 0xFF00ABC0, 0xFF00828E],
    const [0xFFFFCBBB, 0xFFFF6F42, 0xFFE54918],
    const [0xFFEFF3C2, 0xFF9D9C23, 0xFF817616]
  ];

  final OrdinalScale _scale = new OrdinalScale()..range = COLORS;

  @override
  int getColorForKey(key, [int state = 0]) {
    var result = _scale.scale(key);
    return result is Iterable ? colorForState(result, state) : result;
  }

  colorForState(Iterable colors, int state) {
    // Inactive color when another key is active or selected.
    if (state & ChartState.COL_UNSELECTED != 0 ||
        state & ChartState.VAL_UNHIGHLIGHTED != 0) {
      return colors.elementAt(0);
    }

    // Active color when this key is being hovered upon
    if (state & ChartState.COL_PREVIEW != 0 ||
        state & ChartState.VAL_HOVERED != 0) {
      return colors.elementAt(2);
    }

    // All others are normal.
    return colors.elementAt(1);
  }

  @override
  String getFilterForState(int state) => state & ChartState.COL_PREVIEW != 0 ||
      state & ChartState.VAL_HOVERED != 0 ||
      state & ChartState.COL_SELECTED != 0 ||
      state & ChartState.VAL_HIGHLIGHTED != 0 ? 'url(#drop-shadow)' : '';

  @override
  String getOtherColor([int state = 0]) => OTHER_COLORS is Iterable
      ? colorForState(OTHER_COLORS, state)
      : OTHER_COLORS;

  @override
  ChartAxisTheme getMeasureAxisTheme([Scale _]) =>
      const QuantumChartAxisTheme(ChartAxisTheme.FILL_RENDER_AREA, 5);

  @override
  ChartAxisTheme getDimensionAxisTheme([Scale scale]) =>
      scale == null || scale is OrdinalScale
          ? const QuantumChartAxisTheme(0, 10)
          : const QuantumChartAxisTheme(4, 10);

  @override
  AbsoluteRect get padding => const AbsoluteRect(10.0, 40.0, 0.0, 0.0);

  @override
  ChartTextTheme getTextTheme() => const QuantumTextTheme();

  @override
  String get filters => '''
    <filter id="drop-shadow" height="300%" width="300%" y="-100%" x="-100%">
      <feGaussianBlur stdDeviation="2" in="SourceAlpha"></feGaussianBlur>
      <feOffset dy="1" dx="0"></feOffset>
      <feComponentTransfer>
        <feFuncA slope="0.4" type="linear"></feFuncA>
      </feComponentTransfer>
      <feMerge>
        <feMergeNode></feMergeNode>
        <feMergeNode in="SourceGraphic"></feMergeNode>
      </feMerge>
    </filter>
''';

  @override
  String get defaultFont => '14px Roboto';
}

class QuantumChartAxisTheme implements ChartAxisTheme {
  @override
  final axisOuterPadding = 0.1;

  @override
  final axisBandInnerPadding = 0.35;

  @override
  final axisBandOuterPadding = 0.175;

  @override
  final axisTickPadding = 6;

  @override
  final axisTickSize;

  @override
  final axisTickCount;

  @override
  final verticalAxisAutoResize = true;

  @override
  final verticalAxisWidth = 75.0;

  @override
  final horizontalAxisAutoResize = false;

  @override
  final horizontalAxisHeight = 50.0;

  @override
  final ticksFont = '12px Roboto';

  const QuantumChartAxisTheme(this.axisTickSize, this.axisTickCount);
}

class QuantumTextTheme implements ChartTextTheme {
  @override
  final TextStyle axisTicksTextStyle = const TextStyle(
        color: const Color(0xFF424242),
        fontFamily: 'Roboto2',
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        textBaseline: TextBaseline.alphabetic,
        height: 1.43);

  const QuantumTextTheme();
}
