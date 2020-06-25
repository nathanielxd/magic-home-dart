part of magic_home;

class Utilis {
  
  /// Transforms speed (0 to 100) to light specific 'delay' property (0 to 27).
  static int speedToDelay(int speed) {

    if(speed > 100) speed = 100;

    speed = 100 - speed;
    int delay = ((speed * (0x1f - 1)) / 100 + 1).round();

    return delay;
  }

  static int determineBrightness(int red, int green, int blue){
    int max = 0;
    if(red > max) max = red;
    if(green > max) max = green;
    if(blue > max) max = blue;

    return (max * 100 / 255).floor();
  }

  /// Determines the mode of the light according to a code given by the light.
  static LightMode determineMode(String patternCode, String whiteCode) {

    switch(patternCode){
      case '60':
        return LightMode.custom;
      case '41':
      case '61':
      case '62':
        if(whiteCode == '0')
          return LightMode.color;
        return LightMode.warmWhite;
      case '2a':
      case '2b':
      case '2c':
      case '2d':
      case '2e':
      case '2f':
        return LightMode.preset;
    }

    int pc = int.tryParse(patternCode);
    if(pc >= 25 && pc <= 38){
      return LightMode.preset;
    }

    return LightMode.unknown;
  }
}