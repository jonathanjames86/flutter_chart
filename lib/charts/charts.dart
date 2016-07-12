//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

library charted.flutter.charts;

import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:charted_flutter/core/utils.dart';
import 'package:charted_flutter/core/scales.dart';
// import 'package:charted_flutter/core/interpolators.dart';
// import 'package:charted/layout/layout.dart';
import 'package:charted_flutter/core/axis.dart';
import 'package:charted_flutter/core/listenable.dart';
import 'package:charted_flutter/shapes/shapes.dart';
// import 'package:charted/selection/transition.dart';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' hide Axis;

import 'package:logging/logging.dart';
import 'package:quiver/core.dart';

part 'chart_config.dart';
part 'chart_data.dart';
part 'chart_events.dart';
part 'chart_legend.dart';
part 'chart_property.dart';
part 'chart_renderer.dart';
part 'chart_series.dart';
part 'chart_state.dart';
part 'chart_theme.dart';
part 'cartesian_chart_widget.dart';

part 'behaviors/line_marker.dart';
part 'behaviors/mouse_tracker.dart';

part 'cartesian_renderers/bar_chart_renderer.dart';
part 'cartesian_renderers/cartesian_base_renderer.dart';
part 'cartesian_renderers/line_chart_renderer.dart';
part 'cartesian_renderers/line_segment_chart_renderer.dart';
part 'cartesian_renderers/stackedbar_chart_renderer.dart';

part 'src/chart_axis_impl.dart';
part 'src/chart_config_impl.dart';
part 'src/chart_data_impl.dart';
part 'src/chart_events_impl.dart';
part 'src/chart_series_impl.dart';
part 'src/chart_state_impl.dart';

part 'themes/quantum_theme.dart';

final Logger logger = new Logger('charted.charts');
