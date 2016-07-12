//
// Copyright 20.014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.flutter.shapes;

/// Draw a rectangle at [x], [y] which is [width] pixels wide and
/// [height] pixels height.  [topLeft], [topRight], [bottomRight] and
/// [bottomLeft] are the corner radius at each of the four corners.
// String roundedRect(double x, double y, double width, double height, double topLeft,
//         double topRight, double bottomRight, double bottomLeft) =>
//     'M${x+topLeft},$y '
//     'L${x+width-topRight},$y '
//     'Q${x+width},$y ${x+width},${y+topRight}'
//     'L${x+width},${y+height-bottomRight} '
//     'Q${x+width},${y+height} ${x+width-bottomRight},${y+height}'
//     'L${x+bottomLeft},${y+height} '
//     'Q$x,${y+height} $x,${y+height-bottomLeft}'
//     'L$x,${y+topLeft} '
//     'Q$x,$y ${x+topLeft},$y Z';

Path roundedRect(double x, double y, double width, double height, double topLeft,
        double topRight, double bottomRight, double bottomLeft) {
  Path path = new Path();
  path.moveTo(x + topLeft, y);
  path.lineTo(x + width - topRight, y);
  path.quadraticBezierTo(x + width, y, x + width, y + topRight);
  path.lineTo(x + width, y + height - bottomRight);
  path.quadraticBezierTo(x + width, y + height, x + width - bottomRight,
      y + height);
  path.lineTo(x + bottomLeft, y + height);
  path.quadraticBezierTo(x, y + height, x, y + height - bottomLeft);
  path.lineTo(x, y + topLeft);
  path.quadraticBezierTo(x, y, x + topLeft, y);
  path.close();
  return path;
}

/// Draw a rectangle with rounded corners on both corners on the right.
Path rightRoundedRect(double x, double y, double width, double height, double radius) {
  if (width < radius) radius = width;
  if (height < radius * 2) radius = height / 2;
  return roundedRect(x, y, width, height, 0.0, radius, radius, 0.0);
}

/// Draw a rectangle with rounded corners on both corners on the top.
Path topRoundedRect(double x, double y, double width, double height, double radius) {
  if (height < radius) radius = height;
  if (width < radius * 2) radius = width / 2;
  return roundedRect(x, y, width, height, radius, radius, 0.0, 0.0);
}

/// Draw a rectangle with rounded corners on both corners on the right.
Path leftRoundedRect(double x, double y, double width, double height, double radius) {
  if (width < radius) radius = width;
  if (height < radius * 2) radius = height / 2;
  return roundedRect(x, y, width, height, radius, 0.0, 0.0, radius);
}

/// Draw a rectangle with rounded corners on both corners on the top.
Path bottomRoundedRect(double x, double y, double width, double height, double radius) {
  if (height < radius) radius = height;
  if (width < radius * 2) radius = width / 2;
  return roundedRect(x, y, width, height, 0.0, 0.0, radius, radius);
}
