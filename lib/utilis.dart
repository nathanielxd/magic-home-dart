class Utilis {
  static int speedToDelay(int speed) {

    if(speed > 100) speed = 100;

    speed = 100 - speed;
    int delay = ((speed * (0x1f - 1)) / 100 + 1).round();

    return delay;
  }

  static String determineMode(String patternCode) {

    String mode;

    if(patternCode == '61' || patternCode == '62' || patternCode == '41') {
      mode = 'Color';
    }

    if(patternCode == '60') {
      mode = 'Custom';
    }

    for(int i = 25; i <= 38; i++) {
      if(patternCode == i.toString()) {
        mode = 'Preset';
        break;
      }
    }

    if(patternCode == '2a' || patternCode == '2b' || patternCode == '2c' ||
     patternCode == '2d' || patternCode == '2e' || patternCode == '2f') {
       mode = 'Preset';
    }

    return mode;
  }
}