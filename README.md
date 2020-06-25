# Magic Home [![Pub](https://img.shields.io/badge/Pub-1.0.0-brightgreen.svg)](https://pub.dev/packages/magic_home)

DART library that allows you to control Magic Home enabled lights connected to the same LAN.
With this, you can control your bulbs and led strips that work with [Magic Home App](https://play.google.com/store/apps/details?id=com.Zengge.LEDWifiMagicHome).

## Requirements
- A bulb or led strip that works with the Magic Home app;
- Your device connected to the same network as the light.

## Quick Example
```dart
var lights = await Light.discover();

  var light = lights[0];
  await light.connect();

  if(!light.power){
    await light.turnOn();
  }

  await light.setColor(Color(0, 255, 0));
```

## [Documentation](https://github.com/nathanielxd/magic-home-dart/blob/master/DOCS.md)
Available in the DOCS.md file.

## Installation
Add this to your pubspec.yaml file:
```
dependencies:
  magic_home: ^1.0.0
```

### Features
- Discover lights on LAN;
- Turn On/Off;
- Use Color and warm white;
- Turn preset and custom patterns;
- Use time.

### Missing features
- Music and microphone;
- Use built-in timers;
- Other fancy stuff;
- Administration to set WiFi SSiD key.

### Contribute and support
If you need any help or request, open an issue or leave an email. I will answer immediately. If you randomly get errors, it might be because of the light so I can't help it.

I'm also open to collaboration.