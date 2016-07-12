//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.flutter.charts;

/// Model to provide highlight, selection and visibility in a ChartArea.
/// Selection and visibility
///
abstract class ChartState {
  static int COL_SELECTED = 0x001;
  static int COL_UNSELECTED = 0x002;
  static int COL_PREVIEW = 0x004;
  static int COL_HIDDEN = 0x008;
  static int COL_HIGHLIGHTED = 0x010;
  static int COL_UNHIGHLIGHTED = 0x020;
  static int COL_HOVERED = 0x040;
  static int VAL_HIGHLIGHTED = 0x080;
  static int VAL_UNHIGHLIGHTED = 0x100;
  static int VAL_HOVERED = 0x200;

  static const COL_SELECTED_CLASS = 'col-selected';
  static const COL_UNSELECTED_CLASS = 'col-unselected';
  static const COL_PREVIEW_CLASS = 'col-previewed';
  static const COL_HIDDEN_CLASS = 'col-hidden';
  static const COL_HIGHLIGHTED_CLASS = 'col-highlighted';
  static const COL_UNHIGHLIGHTED_CLASS = 'col-unhighlighted';
  static const COL_HOVERED_CLASS = 'col-hovered';
  static const VAL_HIGHLIGHTED_CLASS = 'row-highlighted';
  static const VAL_UNHIGHLIGHTED_CLASS = 'row-unhighlighted';
  static const VAL_HOVERED_CLASS = 'row-hovered';

  static const COLUMN_CLASS_NAMES = const [
    COL_SELECTED_CLASS,
    COL_UNSELECTED_CLASS,
    COL_PREVIEW_CLASS,
    COL_HIGHLIGHTED_CLASS,
    COL_UNHIGHLIGHTED_CLASS,
    COL_HIDDEN_CLASS,
    COL_HOVERED_CLASS
  ];

  static const VALUE_CLASS_NAMES = const [
    COL_SELECTED_CLASS,
    COL_UNSELECTED_CLASS,
    COL_PREVIEW_CLASS,
    COL_HIGHLIGHTED_CLASS,
    COL_UNHIGHLIGHTED_CLASS,
    COL_HIDDEN_CLASS,
    COL_HOVERED_CLASS,
    VAL_HIGHLIGHTED_CLASS,
    VAL_UNHIGHLIGHTED_CLASS,
    VAL_HOVERED_CLASS
  ];

  /// List of selected items.
  /// - Contains a column on CartesianArea if useRowColoring is false.
  /// - Row index in all other cases.
  Iterable<int> get selection;

  /// List of visible items.
  /// - Contains a column on CartesianArea if useRowColoring is false.
  /// - Row index in all other cases.
  Iterable<int> get hidden;

  /// Currently previewed row or column. Hidden items can be previewed
  /// by hovering on the corresponding label in Legend
  /// - Contains a column on CartesianArea if useRowColoring is false.
  /// - Row index in all other cases.
  int preview;

  /// Currently highlighted value, if any, represented as column and row.
  /// Highlight is result of a click on certain value.
  Iterable<Pair<int, int>> highlights;

  /// Currently hovered value, if any, represented as column and row.
  /// Hover is result of mouse moving over a certian value in chart.
  Pair<int, int> hovered;

  /// Ensure that a row or column is visible.
  bool unhide(int id);

  /// Ensure that a row or column is invisible.
  bool hide(int id);

  /// Returns current visibility of a row or column.
  bool isVisible(int id);

  /// Select a row or column.
  bool select(int id);

  /// Unselect a row or column.
  bool unselect(int id);

  /// Returns current selection state of a row or column.
  bool isSelected(int id);

  /// Select a row or column.
  bool highlight(int column, int row);

  /// Unselect a row or column.
  bool unhighlight(int column, int row);

  /// Returns current selection state of a row or column.
  bool isHighlighted(int column, int row);

  factory ChartState({bool isMultiSelect: false}) =>
      new DefaultChartStateImpl(isMultiSelect: isMultiSelect);
}
