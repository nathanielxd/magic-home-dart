# Magic Home [![Pub](https://img.shields.io/badge/Pub-0.9.0-brightgreen.svg)](https://pub.dev/packages/magic_home)

A library that imports functionality from the Magic Home app, allowing control of smart lights

## Installation

Add this to your pubspec.yaml file:
```
dependencies:
  magic_home: ^0.9.0
```


## Example

```dart
import 'package:magic_home/magic_home.dart';

main() {

  Light.discover().then((lights){
    lights[0].setColor(255, 0, 128);
  });
}
```
