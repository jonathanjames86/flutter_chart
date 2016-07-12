//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.flutter.charts;

class DefaultChartConfigImpl implements ChartConfig {
  final Map<String, ChartAxisConfig> _measureAxisRegistry = {};
  final Map<int, ChartAxisConfig> _dimensionAxisRegistry = {};
  final SubscriptionsDisposer _disposer = new SubscriptionsDisposer();

  bool _isRTL = false;
  Iterable<ChartSeries> _series;
  Iterable<int> _dimensions;
  StreamSubscription _dimensionsSubscription;

  @override
  Rect minimumSize = new Rect.fromLTWH(0.0, 0.0, 400.0, 300.0);

  @override
  bool isLeftAxisPrimary = false;

  @override
  bool autoResizeAxis = true;

  @override
  Iterable<String> displayedMeasureAxes;

  @override
  bool renderDimensionAxes = true;

  @override
  bool switchAxesForRTL = true;

  DefaultChartConfigImpl(
      Iterable<ChartSeries> series, Iterable<int> dimensions) {
    this.series = series;
    this.dimensions = dimensions;
  }

  @override
  set series(Iterable<ChartSeries> values) {
    assert(values != null && values.isNotEmpty);

    _disposer.dispose();
    _series = values;
  }

  @override
  Iterable<ChartSeries> get series => _series;

  @override
  set dimensions(Iterable<int> values) {
    _dimensions = values;

    if (_dimensionsSubscription != null) {
      _dimensionsSubscription.cancel();
      _dimensionsSubscription = null;
    }
  }

  @override
  Iterable<int> get dimensions => _dimensions;

  @override
  void registerMeasureAxis(String id, ChartAxisConfig config) {
    assert(config != null);
    _measureAxisRegistry[id] = config;
  }

  @override
  ChartAxisConfig getMeasureAxis(String id) => _measureAxisRegistry[id];

  @override
  void registerDimensionAxis(int column, ChartAxisConfig config) {
    assert(config != null);
    assert(dimensions.contains(column));
    _dimensionAxisRegistry[column] = config;
  }

  @override
  ChartAxisConfig getDimensionAxis(int column) =>
      _dimensionAxisRegistry[column];

  @override
  set isRTL(bool value) {
    if (_isRTL != value && value != null) {
      _isRTL = value;
    }
  }

  @override
  bool get isRTL => _isRTL;
}
