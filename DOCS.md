# Documentation

## Discovery
Use this static method to discover all available magic home lights on your network:
```dart
var lights = await Light.discover();
```

This will take approximately 1 second.

If you have many leds you might need more time to discover all of them, therefore you'll have to use the LightDiscovey class and set a custom timeout.
```dart
LightDiscovery.timeout = 2000;
var lights = await LightDiscovery.discover();
```

`Light.discover()` and `LightDiscovery.discover()` are doing the same thing.

## Light
The light entity contains almost all logic of the library.

### Constructor
1. Initialize your light with its local ip address:
```dart
var light = Light('192.168.1.1');
```

2. Connect to it:
```dart
await light.connect();
```

3. You're now ready to use it.

### Methods
These are the methods used to interact with the light.

#### Set power
Use this to turn it on or off:
```dart
await light.turnOn(); // or light.setPower(true);
await light.turnOff(); // or light.setPower(false);
```

#### Set color
Set a color. Each value has to be between 0 and 255.
```dart
await light.setColor(Color(0, 127, 243));
```

Or just use a preset color:
```dart
await light.setColor(Color.purple);
```

#### Set white
Set cold white:
```dart
await light.setColdWhite(255); // or light.setColor(Color.white);
```

If you have a bulb or strip that supports warm white, use:
```dart
await light.setWarmWhite(255);
```

#### Set preset patterns
The light has some factory patterns:
```dart
await light.setPresetPattern(PresetPattern.PurpleGradualChange, 50);
```

#### Set custom patterns
Make your own patterns by using this:
```dart
var colors = <Color>[
    Color(255, 0, 0),
    Color(0, 255, 0),
    Color.green
];

await light.setCustomPattern(colors, TransitionType.Gradual, 50);
```

#### Refresh
The light's properties are populated whenever you use any method, but sometimes the light might fail so it's recommended to use this from time to time to send a request to the light and get it's status (Light mode, Color, Brightness, etc.):
```dart
await light.refresh();
```

#### Print
Print your light's status:
```dart
print(light.toString());
```

## Color
Color entity for library.

Make a new color:
```dart
var color = Color(25, 12, 164);
```

Or use a pre-set:
```dart
var color = Color.purple;
```

Empty / Transparent / Black:
```dart
var color = Color.empty;
```