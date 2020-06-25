part of magic_home;

/// Color entity of the Magic Home library.
class Color {
  int r;
  int g;
  int b;

  /// Creates a new color object.
  /// 
  /// The red, green and blue values have to be between 0 and 255.
  Color(int red, int green, int blue){
    r = red;
    g = green;
    b = blue;
    if(r > 255) r = 255;
    if(g > 255) g = 255;
    if(b > 255) b = 255;
  }

  /// Prints the current color.
  /// 
  /// Eg. R25 G123 B0.
  @override
  String toString() => 'R$r G$g B$b';

  // Pre-set colors
  /// Empty color (R0 G0 B0).
  static Color get empty => Color(0, 0, 0);
  /// White color (R255 G255 B255).
  static Color get white => Color(255, 255, 255);

  /// Red color (R255 G0 B0).
  static Color get red => Color(255, 0, 0);
  /// Green color (R0 G255 B0).
  static Color get green => Color(0, 255, 0);
  /// Blue color (R0 G0 B255).
  static Color get blue  => Color(0, 0, 255);
  /// Purple color (R255 G0 B255).
  static Color get purple => Color(255, 0, 255);
  /// Orange color (R255 G255 B0).
  static Color get orange => Color(255, 255, 0);
  /// Cyan color (R0 G255 B255).
  static Color get cyan => Color(0, 255, 255);
}