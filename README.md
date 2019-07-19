# Magic Home

A library that imports functionality from the Magic Home app, allowing control of smart lights

## Installation

TODO

## Example

```dart
import 'package:magic_home/magic_home.dart';

main() {

  Light.discover().then((lights){
    lights[0].setColor(255, 0, 128);
  });
}
```
