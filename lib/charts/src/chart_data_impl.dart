//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.flutter.charts;

class DefaultChartDataImpl implements ChartData {
  Iterable<ChartColumnSpec> _columns;
  Iterable<Iterable> _rows;

  SubscriptionsDisposer _disposer = new SubscriptionsDisposer();

  DefaultChartDataImpl(
      Iterable<ChartColumnSpec> columns, Iterable<Iterable> rows) {
    this.columns = columns;
    this.rows = rows;
  }

  set columns(Iterable<ChartColumnSpec> value) {
    assert(value != null);

    // Create a copy of columns.  We do not currently support
    // changes to the list of columns.  Any changes to the spec
    // will be applied at the next ChartBase.draw();
    this._columns = new List<ChartColumnSpec>.from(value);
  }

  Iterable<ChartColumnSpec> get columns => _columns;

  set rows(Iterable<Iterable> value) {
    assert(value != null);
    _rows = value;
  }

  Iterable<Iterable> get rows => _rows;

  @override
  String toString() {
    var cellDataLength = new List.filled(rows.elementAt(0).length, 0);
    for (var i = 0; i < columns.length; i++) {
      if (cellDataLength[i] < columns.elementAt(i).label.toString().length) {
        cellDataLength[i] = columns.elementAt(i).label.toString().length;
      }
    }
    for (var row in rows) {
      for (var i = 0; i < row.length; i++) {
        if (cellDataLength[i] < row.elementAt(i).toString().length) {
          cellDataLength[i] = row.elementAt(i).toString().length;
        }
      }
    }

    var totalLength = 1; // 1 for the leading '|'.
    for (var length in cellDataLength) {
      // 3 for the leading and trailing ' ' padding and trailing '|'.
      totalLength += length + 3;
    }

    // Second pass for building the string buffer and pad each cell with space
    // according to the difference between cell string length and max length.
    var strBuffer = new StringBuffer();
    strBuffer.write('-' * totalLength + '\n');
    strBuffer.write('|');

    // Process columns.
    for (var i = 0; i < columns.length; i++) {
      var label = columns.elementAt(i).label;
      var lengthDiff = cellDataLength[i] - label.length;
      strBuffer.write(' ' * lengthDiff + ' $label |');
    }
    strBuffer.write('\n' + '-' * totalLength + '\n');

    // Process rows.
    for (var row in rows) {
      strBuffer.write('|');
      for (var i = 0; i < row.length; i++) {
        var data = row.elementAt(i).toString();
        var lengthDiff = cellDataLength[i] - data.length;
        strBuffer.write(' ' * lengthDiff + ' $data |');

        if (i == row.length - 1) {
          strBuffer.write('\n' + '-' * totalLength + '\n');
        }
      }
    }
    return strBuffer.toString();
  }
}
