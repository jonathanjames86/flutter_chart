part of charted.flutter.charts;

class CartesianChartWidget extends LeafRenderObjectWidget {
  CartesianChartWidget(this.property, {Key key}) : super(key: key);

  ChartProperty property;
  CartesianChartRenderObject renderObject;

  @override
  CartesianChartRenderObject createRenderObject(BuildContext context) {
    return new CartesianChartRenderObject(property: property);
  }
}

// TODO(midoringo): listen to observable list change.
class CartesianChartRenderObject extends RenderConstrainedBox {
  /// Default identifiers used by the measure axes
  static const MEASURE_AXIS_IDS = const ['_default'];

  /// Orientations used by measure axes. First, when "x" axis is the primary
  /// and the only dimension. Second, when "y" axis is the primary and the only
  /// dimension.
  static const MEASURE_AXIS_ORIENTATIONS = const [
    const [ORIENTATION_LEFT, ORIENTATION_RIGHT],
    const [ORIENTATION_BOTTOM, ORIENTATION_TOP]
  ];

  /// Orientations used by the dimension axes. First, when "x" is the
  /// primary dimension and the last one for cases where "y" axis is primary
  /// dimension.
  static const DIMENSION_AXIS_ORIENTATIONS = const [
    const [ORIENTATION_BOTTOM, ORIENTATION_LEFT],
    const [ORIENTATION_LEFT, ORIENTATION_BOTTOM]
  ];

  /// Mapping of measure axis Id to it's axis.
  final _measureAxes = new LinkedHashMap<String, DefaultChartAxisImpl>();

  /// Mapping of dimension column index to it's axis.
  final _dimensionAxes = new LinkedHashMap<int, DefaultChartAxisImpl>();

  ChartProperty property;
  ChartAreaLayout chartLayout = new ChartAreaLayout();
  Iterable<ChartSeries> _series;
  TapGestureRecognizer _tap;
  ChartState state;
  String _orientRTL(String orientation) => orientation;

  /// Indicates whether any renderers need bands on primary dimension
  final List<int> dimensionsUsingBands = [];

  CartesianChartRenderObject({this.property})
      : super(child: null,
      additionalConstraints: const BoxConstraints.expand()) {
         _tap = new TapGestureRecognizer()
           ..onTapDown = _handleTapDown
           ..onTap = _handleTap
           ..onTapUp = _handleTapUp
           ..onTapCancel = _handleTapCancel;
      }

  void _handleTapDown(TapDownDetails details) { }

  void _handleTapUp(TapUpDetails details) {
    // _painter.handleTap(globalPosition);
    markNeedsPaint();
  }

  void _handleTap() {}

  void _handleTapCancel() {}

  @override
  bool hitTestSelf(Point position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }

  // TODO (midoringo): add the gesture handling code.
  // @override
  // void handleSemanticTap() => _handleTap();

  /// All columns rendered by a series must be of the same type.
  bool _isSeriesValid(ChartSeries s) {
    var first = property.data.columns.elementAt(s.measures.first).type;
    return s.measures.every((i) =>
        (i < property.data.columns.length) && property.data.columns.elementAt(i).type == first);
  }

  /// Gets measure axis from cache - creates a new instance of _ChartAxis
  /// if one was not already created for the given [axisId].
  DefaultChartAxisImpl _getMeasureAxis(String axisId) {
    _measureAxes.putIfAbsent(axisId, () {
      var axisConf = property.config.getMeasureAxis(axisId),
          axis = axisConf != null
              ? new DefaultChartAxisImpl.withAxisConfig(this, axisConf)
              : new DefaultChartAxisImpl(this);
      return axis;
    });
    return _measureAxes[axisId];
  }

  /// Gets a dimension axis from cache - creates a new instance of _ChartAxis
  /// if one was not already created for the given dimension [column].
  DefaultChartAxisImpl _getDimensionAxis(int column) {
    _dimensionAxes.putIfAbsent(column, () {
      var axisConf = property.config.getDimensionAxis(column),
          axis = axisConf != null
              ? new DefaultChartAxisImpl.withAxisConfig(this, axisConf)
              : new DefaultChartAxisImpl(this);
      return axis;
    });
    return _dimensionAxes[column];
  }

  Iterable<Scale> get dimensionScales =>
      property.config.dimensions.map((int column) => _getDimensionAxis(column).scale);

  Iterable<Scale> measureScales(ChartSeries series) {
    var axisIds = isNullOrEmpty(series.measureAxisIds)
        ? MEASURE_AXIS_IDS
        : series.measureAxisIds;
    return axisIds.map((String id) => _getMeasureAxis(id).scale);
  }


  Rect _computeChartSize(Offset offset) {
    double width = size.width, height = size.height;

    var padding = property.theme.padding;
    var paddingLeft = property.config.isRTL ? padding.end : padding.start;
    Rect current = new Rect.fromLTWH(
        paddingLeft + offset.dx,
        padding.top + offset.dy,
        width - (padding.start + padding.end),
        height - (padding.top + padding.bottom));
    if (chartLayout.chartArea == null || chartLayout.chartArea != current) {
        chartLayout.chartArea = current;

    // TODO(midoringo): handle other panes (Behaviors).
    }
    return current;
  }

  // TODO(midoringo): Handle chart behaviors, events, and legend.
  @override
  void paint(PaintingContext context, Offset offset) {
    assert(size.width != null);
    assert(size.height != null);
    assert(property.data != null && property.config != null);
    assert(property.config.series != null && property.config.series.isNotEmpty);

    // Compute chart sizes and filter out unsupported series
    _computeChartSize(offset);
    var series = property.config.series
            .where((s) => _isSeriesValid(s) && s.renderer.prepare(this, s));

    // Save the list of valid series and initialize axes.
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);

    _series = series;
    _initAxes(context.canvas);
    context.canvas.restore();

    for (ChartSeries s in series) {
      // TODO(midoringo): set up event handling
      var renderArea = chartLayout.renderArea;
      Rect chartRenderArea = new Rect.fromLTWH(renderArea.left + offset.dx,
      renderArea.top + offset.dy, renderArea.width, renderArea.height);
      (s.renderer as CartesianRenderer)
          .paint(context.canvas, chartRenderArea);
    }
  }

  /// Initialize the axes - required even if the axes are not being displayed.
  _initAxes(Canvas canvas, {bool preRender: false}) {
    Map measureAxisUsers = <String, Iterable<ChartSeries>>{};

    // Create necessary measures axes.
    // If measure axes were not configured on the series, default is used.
    for (var s in _series) {
    // _series.forEach((ChartSeries s) {
      var measureAxisIds =
          isNullOrEmpty(s.measureAxisIds) ? MEASURE_AXIS_IDS : s.measureAxisIds;
      measureAxisIds.forEach((axisId) {
        _getMeasureAxis(axisId); // Creates axis if required
        var users = measureAxisUsers[axisId];
        if (users == null) {
          measureAxisUsers[axisId] = [s];
        } else {
          users.add(s);
        }
      });
    }

    // Now that we know a list of series using each measure axis, configure
    // the input domain of each axis.
    measureAxisUsers.forEach((id, listOfSeries) {
      var sampleCol = listOfSeries.first.measures.first,
          sampleColSpec = property.data.columns.elementAt(sampleCol),
          axis = _getMeasureAxis(id),
          domain;

      if (sampleColSpec.useOrdinalScale) {
        throw new UnsupportedError(
            'Ordinal measure axes are not currently supported.');
      } else {
        // Extent is available because [ChartRenderer.prepare] was already
        // called (when checking for valid series in [draw].
        Iterable extents = listOfSeries.map((s) => s.renderer.extent).toList();
        var lowest = min(extents.map((e) => e.min)),
            highest = max(extents.map((e) => e.max));

        // Use default domain if lowest and highest are the same, right now
        // lowest is always 0 unless it is less than 0 - change to lowest when
        // we make use of it.
        domain = highest == lowest
            ? (highest == 0
                ? [0, 1]
                : (highest < 0 ? [highest, 0] : [0, highest]))
            : (lowest <= 0 ? [lowest, highest] : [0, highest]);
      }
      axis.initAxisDomain(sampleCol, false, domain);
    });

    // Configure dimension axes.
    int dimensionAxesCount = property.useTwoDimensionAxes ? 2 : 1;
    property.config.dimensions.take(dimensionAxesCount).forEach((int column) {
      var axis = _getDimensionAxis(column),
          sampleColumnSpec = property.data.columns.elementAt(column),
          values = property.data.rows.map((row) => row.elementAt(column)),
          domain;

      if (sampleColumnSpec.useOrdinalScale) {
        domain = values.map((e) => e.toString()).toList();
      } else {
        var extent = new Extent.items(values);
        domain = [extent.min, extent.max];
      }
      axis.initAxisDomain(column, true, domain);
    });

    // See if any dimensions need "band" on the axis.
    dimensionsUsingBands.clear();
    List<bool> usingBands = [false, false];
    _series.forEach((ChartSeries s) =>
        (s.renderer as CartesianRenderer).dimensionsUsingBand.forEach((x) {
          if (x <= 1 && !(usingBands[x])) {
            usingBands[x] = true;
            dimensionsUsingBands.add(property.config.dimensions.elementAt(x));
          }
        }));

    // List of measure and dimension axes that are displayed
    assert(isNullOrEmpty(property.config.displayedMeasureAxes) ||
        property.config.displayedMeasureAxes.length < 2);
    var measureAxesCount = dimensionAxesCount == 1 ? 2 : 0,
        displayedMeasureAxes =
            (isNullOrEmpty(property.config.displayedMeasureAxes)
                ? _measureAxes.keys.take(measureAxesCount)
                : property.config.displayedMeasureAxes.take(measureAxesCount))
            .toList(growable: false),
        displayedDimensionAxes =
        property.config.dimensions.take(dimensionAxesCount).toList(
            growable: false);

    // Compute size of the dimension axes
    if (property.config.renderDimensionAxes != false) {
      var dimensionAxisOrientations = property.config.isLeftAxisPrimary
          ? DIMENSION_AXIS_ORIENTATIONS.last
          : DIMENSION_AXIS_ORIENTATIONS.first;
      for (int i = 0, len = displayedDimensionAxes.length; i < len; ++i) {
        var axis = _dimensionAxes[displayedDimensionAxes[i]],
            orientation = _orientRTL(dimensionAxisOrientations[i]);
        axis.prepareToPaint(orientation);
        chartLayout._axes[orientation] = axis.size;
      }
    }

    // Compute size of the measure axes
    if (displayedMeasureAxes.isNotEmpty) {
      var measureAxisOrientations = property.config.isLeftAxisPrimary
          ? MEASURE_AXIS_ORIENTATIONS.last
          : MEASURE_AXIS_ORIENTATIONS.first;
      displayedMeasureAxes.asMap().forEach((int index, String key) {
        var axis = _measureAxes[key],
            orientation = _orientRTL(measureAxisOrientations[index]);
        axis.prepareToPaint(orientation);
        chartLayout._axes[orientation] = axis.size;
      });
    }

    // Consolidate all the information that we collected into final layout
    _computeLayout(
        displayedMeasureAxes.isEmpty
        && property.config.renderDimensionAxes == false);

    // Domains for all axes have been taken care of and _ChartAxis ensures
    // that the scale is initialized on visible axes. Initialize the scale on
    // all invisible measure scales.
    if (_measureAxes.length != displayedMeasureAxes.length) {
      _measureAxes.keys.forEach((String axisId) {
        if (displayedMeasureAxes.contains(axisId)) return;
        _getMeasureAxis(axisId).initAxisScale(
          [chartLayout.renderArea.height, 0]);
      });
    }

    // Draw the visible measure axes, if any.
    if (displayedMeasureAxes.isNotEmpty) {
      for (var measureAxis in displayedMeasureAxes) {
        _getMeasureAxis(measureAxis).paint(canvas);
      }
    }

    // Draw the dimension axes, unless asked not to.
    if (property.config.renderDimensionAxes != false) {
      for (var dimensionAxis in displayedDimensionAxes) {
        _getDimensionAxis(dimensionAxis).paint(canvas);
      }
    } else {
      // Initialize scale on invisible axis
      var dimensionAxisOrientations = property.config.isLeftAxisPrimary
          ? DIMENSION_AXIS_ORIENTATIONS.last
          : DIMENSION_AXIS_ORIENTATIONS.first;
      for (int i = 0; i < dimensionAxesCount; ++i) {
        var column = property.config.dimensions.elementAt(i),
            axis = _dimensionAxes[column],
            orientation = dimensionAxisOrientations[i];
        axis.initAxisScale(orientation == ORIENTATION_LEFT
            ? [chartLayout.renderArea.height, 0]
            : [0, chartLayout.renderArea.width]);
      };
    }
  }

  // Compute chart render area size and positions of all elements
  _computeLayout(bool notRenderingAxes) {
    if (notRenderingAxes) {
      chartLayout.renderArea =
          new Rect.fromLTWH(0.0, 0.0,
              chartLayout.chartArea.height, chartLayout.chartArea.width);
      return;
    }

    var top = chartLayout.axes[ORIENTATION_TOP],
        left = chartLayout.axes[ORIENTATION_LEFT],
        bottom = chartLayout.axes[ORIENTATION_BOTTOM],
        right = chartLayout.axes[ORIENTATION_RIGHT];

    var renderAreaHeight = chartLayout.chartArea.height -
            (top.height + chartLayout.axes[ORIENTATION_BOTTOM].height),
        renderAreaWidth = chartLayout.chartArea.width -
            (left.width + chartLayout.axes[ORIENTATION_RIGHT].width);

    chartLayout.renderArea =
        new Rect.fromLTWH(left.width, top.height, renderAreaWidth, renderAreaHeight);

    chartLayout._axes
      ..[ORIENTATION_TOP] = new Rect.fromLTWH(left.width, 0.0, renderAreaWidth,
          top.height)
      ..[ORIENTATION_RIGHT] = new Rect.fromLTWH(
          left.width + renderAreaWidth, top.top, right.width, renderAreaHeight)
      ..[ORIENTATION_BOTTOM] = new Rect.fromLTWH(left.width,
          top.height + renderAreaHeight, renderAreaWidth, bottom.height)
      ..[ORIENTATION_LEFT] =
          new Rect.fromLTWH(left.width, top.height, left.width, renderAreaHeight);
  }
}

class ChartAreaLayout {
  final _axes = <String, Rect>{
    ORIENTATION_LEFT: new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0),
    ORIENTATION_RIGHT: new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0),
    ORIENTATION_TOP: new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0),
    ORIENTATION_BOTTOM: new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0)
  };

  UnmodifiableMapView<String, Rect> _axesView;

  get axes => _axesView;

  @override
  Rect renderArea;

  @override
  Rect chartArea;

  ChartAreaLayout() {
    _axesView = new UnmodifiableMapView(_axes);
  }
}
