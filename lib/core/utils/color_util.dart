//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.flutter.core.utils;

// TODO(midoringo): Add HSL <-> RGB support.
/// Represents a single color for use in visualizations.  Currently, supports
/// representing and conversion between RGB, RGBA and hex formats.
class ColorUtil {

  /// Create an instance using a string representing color in RGB color space.
  /// The input string, [value], can be one of the following formats:
  ///
  ///    #RGB
  ///    #RRGGBB
  ///
  ///    rgb(R, G, B)
  ///    rgba(R, G, B, A)
  ///
  /// R, G and B represent intensities of Red, Green and Blue channels and A
  /// represents the alpha channel (transparency)
  ///
  /// When using these formats:
  ///     0 <= R,G,B <= 255
  ///     0 <= A <= 1.0
  static Color fromRgbString(String value) =>
      isHexColorString(value) ? _fromHexString(value) : _fromRgbString(value);

  /// Given RGB values create hex string from it.
  static String rgbToHexString(int r, int g, int b) {
    String _hexify(int v) {
      return v < 0x10
          ? "0" + math.max(0, v).toInt().toRadixString(16)
          : math.min(255, v).toInt().toRadixString(16);
    }
    return '#${_hexify(r)}${_hexify(g)}${_hexify(b)}';
  }

  /// RegExp to test if a given string is a hex color string
  static final RegExp hexColorRegExp =
      new RegExp(r'^#([0-9a-f]{3}){1,2}$', caseSensitive: false);

  /// Tests if [str] is a hex color
  static bool isHexColorString(String str) => hexColorRegExp.hasMatch(str);

  /// RegExp to test if a given string is rgb() or rgba() color.
  static final RegExp rgbaColorRegExp = new RegExp(
      r'^(rgb|rgba)?\(\d+,\s?\d+,\s?\d+(,\s?(0|1)?(\.\d)?\d*)?\)$',
      caseSensitive: false);

  /// Tests if [str] is a color represented by rgb() or rgba() or hex string
  static bool isRgbColorString(String str) =>
      isHexColorString(str) || rgbaColorRegExp.hasMatch(str);

  /// RegExp to test if a given string is hsl() or hsla() color.
  static final RegExp hslaColorRegExp = new RegExp(
      r'^(hsl|hsla)?\(\d+,\s?\d+%,\s?\d+%(,\s?(0|1)?(\.\d)?\d*)?\)$',
      caseSensitive: false);

  /// Tests if [str] is a color represented by hsl() or hsla()
  static bool isHslColorString(String str) => hslaColorRegExp.hasMatch(str);

  /// Create an instance using the passed RGB string.
  static Color _fromRgbString(String value) {
    int pos = (value.startsWith('rgb(') || value.startsWith('RGB('))
        ? 4
        : (value.startsWith('rgba(') || value.startsWith('RGBA(')) ? 5 : 0;
    if (pos != 0) {
      final params = value.substring(pos, value.length - 1).split(',');
      int r = int.parse(params[0]),
          g = int.parse(params[1]),
          b = int.parse(params[2]);
      int a = params.length == 3 ? 255 : int.parse(params[3]);
      return new Color.fromARGB(a, r, g, b);
    }
    return new Color.fromARGB(0, 0, 0, 0);
  }

  /// Create an instance using the passed HEX string.
  /// Assumes that the string starts with a '#' before HEX chars.
  static Color _fromHexString(String hex) {
    if (isNullOrEmpty(hex) || (hex.length != 4 && hex.length != 7)) {
      return new Color.fromARGB(0, 0, 0, 0);
    }
    int rgb = 0;

    hex = hex.substring(1);
    if (hex.length == 3) {
      for (int i = 0; i < hex.length; i++) {
        final val = int.parse(hex[i], radix: 16);
        rgb = (rgb * 16 + val) * 16 + val;
      }
    } else if (hex.length == 6) {
      rgb = int.parse(hex, radix: 16);
    }

    return new Color.fromARGB(
      0xFF, (rgb & 0xff0000) >> 0x10, (rgb & 0xff00) >> 8, (rgb & 0xff));
  }
}
