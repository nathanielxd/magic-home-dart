part of magic_home;

/// Any Magic Home light has either **ledenet** or **ledenet_original** protocol.
/// 
/// **Ledenet** are usually bulbs and SMD 5050 strips - those with no RGB separation into different leds.
/// Those SMD 3528 strips which have different leds for the three colors are usually **ledenet_original**.
enum LedProtocol {ledenet, ledenet_original, unknown}

enum LightMode {color, warmWhite, preset, custom, unknown}

/// Magic Home light.
/// 
/// See https://github.com/nathanielxd/magic-home-dart.
class Light {

  /// The network socket of the light.
  Socket socket;
  /// Ip address of this light instance.
  String address;

  /// Whether the socket is connected or not.
  bool connected;
  /// Specifies whether the light is on or off.
  bool power;
  /// Specifies the mode of the light (Color, Preset, White, Custom).
  LightMode mode;
  /// The color of the light.
  Color color;
  /// The warm white value of the light.
  int warmWhite;
  /// The brightness of the light, from 0 to 100.
  int brightness;
  /// The date and time of the light.
  DateTime time;
  /// The protocol of the instance.
  LedProtocol protocol;

  /// Specifies whether or not to append checksum to outgoing requests.
  /// True by default.
  bool useCsum = true;

  /// The receive timeout of the socket in milliseconds.
  int timeout = 1000;

  //Constants.
  int _port = 5577;

  /// Creates a new light instance.
  /// Remember to connect it by calling `connect();`
  Light(this.address);

  /// Connects the socket to the light and sends a request to get light's status.
  void connect() async {
    socket = await Socket.connect(address, _port);
    _startListening();
    protocol = await _getProtocol();
    connected = true;
    await refresh();
  }

  /// Send a broadcast message on the LAN to get all available lights.
  /// This operation will take 1 second by default. You can modify the timeout property to change the execution time.
  static Future<List<Light>> discover() => LightDiscovery.discover();

  /// Sends a request to get the light's status.
  /// Updates this instance with current bulbs's mode, time, status, protocol, color, brightness.
  /// This operation usually takes between 80 and 500 milliseconds.
  void refresh() async {

    Uint8List dataRaw;

    if(protocol == LedProtocol.ledenet){
      dataRaw = await _send([0x81, 0x8a, 0x8b], expectResponse: true);
    }
    else if(protocol == LedProtocol.ledenet_original){
      dataRaw = await _send([0xef, 0x01, 0x77], expectResponse: true);
    }

    var dataHex = _dataToHex(dataRaw);

    if(protocol == LedProtocol.ledenet_original && dataHex[1] == '01'){
      useCsum = false;
    }

    if(dataHex[2] == '23') {
      power = true;
    } else if(dataHex[2] == '24'){
      power = false;
    }

    mode = Utilis.determineMode(dataHex[3], dataHex[9]);

    switch(mode){
      case LightMode.color:
        color = Color(dataRaw[6].toInt(), dataRaw[7].toInt(), dataRaw[8].toInt());
        warmWhite = 0;
        break;
      case LightMode.warmWhite:
        color = Color.empty;
        warmWhite = dataRaw[9].toInt();
        break;
      case LightMode.preset:
      case LightMode.unknown:
      case LightMode.custom:
        color = Color.empty;
        warmWhite = 0;
        break;
    }

    _updateBrightness();

    time = await _getTime();
  }

  /// Sets the light ON or OFF.
  Future<void> setPower(bool power) {
    if(power)
      return turnOn();
    else return turnOff();
  }

  /// Turns the light ON.
  Future<void> turnOn() async {
    if(protocol == LedProtocol.ledenet)
      await _send([0x71, 0x23, 0x0f]);
    else await _send([0xcc, 0x23, 0x33]);

    // Populate field.
    power = true;
  }

  /// Turns the light OFF.
  Future<void> turnOff() async {
    if(protocol == LedProtocol.ledenet)
      await _send([0x71, 0x24, 0x0f]);
    else await _send([0xcc, 0x24, 0x33]);

    // Populate field.
    this.power = false;
  }

  /// Sets the color of the light.
  /// 
  /// The red, green and blue values of the colors have to be between 0 and 255.
  Future<void> setColor(Color color) async {
    if(protocol == LedProtocol.ledenet)
      await _send([0x31, color.r, color.g, color.b, 0x00, 0x00, 0x0f]);
    else await _send([0x56, color.r, color.g, color.b, 0xaa]);

    // Populate fields.
    this.color = color;
    warmWhite = 0;
    _updateBrightness();
  }

  /// Sets all the red, green and blue color to the same value to create cold white light.
  /// 
  /// [white] value is to be between 0 and 255.
  Future<void> setColdWhite(int white) 
  => setColor(Color(white, white, white));

  /// Sets warm white if the light support it.
  /// 
  /// If the protocol of the light is [ledenet_original] then it will set cold white.
  /// 
  /// [white] values is to be between 0 and 255.
  Future<void> setWarmWhite(int white) async {
    if(protocol == LedProtocol.ledenet)
      await _send([0x31, 0, 0, 0, white, 0x0f, 0x0f]);
    else await setColdWhite(white);
  }

  /// Sets a preset pattern.
  /// 
  /// Specify the speed from 0 to 100.
  void setPresetPattern(int pattern, int speed) async {
    await _send([0x61, pattern, Utilis.speedToDelay(speed), 0x0f]);

    // Populate field.
    mode = LightMode.preset;
  }

  /// Sets the light a custom pattern.
  /// Use a list of Color objects to assign a list of colors the light will cycle through.
  /// 
  /// Specify the transition type (Gradual, Strobe or Jump) and a speed value from 0 to 100.
  Future<void> setCustomPattern(List<Color> colors, int transitionType, int speed) async {

    List<int> message = List<int>();
    message.add(0x51);

    if(colors.isNotEmpty) {
      message.addAll([colors[0].r, colors[0].g, colors[0].b]);
    }

    for(int i = 1; i < colors.length; i++) {
      message.add(0);
      message.addAll([colors[i].r, colors[i].g, colors[i].b]);
    }

    for(int i = 0; i < 16 - colors.length; i++) {
      message.addAll([0, 1, 2, 3]);
    }

    message.addAll([0x00, Utilis.speedToDelay(speed), transitionType, 0xff, 0x0f]);

    await _send(message);

    // Populate field.
    mode = LightMode.custom;
  }

  /// Sets the date and time of the light.
  Future<void> setTime(DateTime dateTime) async {
    await _send([
      0x10, 0x14,
      dateTime.year - 2000,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.weekday,
      0x00, 0x0f
    ]);

    time = await _getTime();
  }

  // Private methods.

  /// Send a request to the light to get the time.
  Future<DateTime> _getTime() async {
    var data = await _send([0x11, 0x1a, 0x1b, 0x0f], expectResponse: true);
    return DateTime(
      data[3] + 2000,
      data[4],
      data[5],
      data[6],
      data[7],
      data[8]
    );
  }

  /// Update the brightness of this light based on the color values.
  void _updateBrightness(){
    if(mode == LightMode.color)
      brightness = Utilis.determineBrightness(color.r, color.g, color.b);
    else brightness = Utilis.determineBrightness(warmWhite, warmWhite, warmWhite);
  }

  /// Get the protocol of the light.
  Future<LedProtocol> _getProtocol() async {
    try {
      await _send([0x81, 0x8a, 0x8b], expectResponse: true);
      return LedProtocol.ledenet;
    } on TimeoutException {
      try {
        await _send([0xef, 0x01, 0x77], expectResponse: true);
        return LedProtocol.ledenet_original;
      } on TimeoutException {
        return LedProtocol.unknown;
      }
    }
  }

  // Socket sending and reading.

  Completer<Uint8List> _dataCompleter = Completer();

  /// Start listening to the socket.
  void _startListening() 
  => socket.listen((data)
    => _dataCompleter.complete(data));

  /// Sends bytes list to the socket and returns the response if you set
  /// [expectResponse] to true. Otherwise, it returns null.
  /// 
  /// If you are expecting a response and [timeout] runs out, 
  /// it will throw a [TimeoutException].
  Future<Uint8List> _send(List<int> data, {bool expectResponse = false}) async {
    // Calculate and append csum.
    int csum = 0;
    for(int i = 0; i < data.length; i++) {
      csum += data[i];
    }
    csum &= 0xFF;
    data.add(csum);
    
    // Create the message from the byte list and send it.
    var message = Uint8List.fromList(data);
    socket.add(message);

    if(expectResponse){
    // Wait for response.
      Uint8List _data = await _dataCompleter.future
        .timeout(Duration(milliseconds: timeout));

      // Reset the completer.
      _dataCompleter = Completer();

      return _data;
    }
    else return null;
  }

  /// Turn bytes list into hexadecimal string list.
  List<String> _dataToHex(Uint8List data) 
  => data.map((byte) => byte.toRadixString(16)).toList();

  /// Returns a string containing all information about this instance (ex. color mode, color values, etc.).
  @override
  String toString() => '''[$address] Power $power, Mode $mode, Color $color 
    WW$warmWhite, Brightness $brightness, Time $time, Protocol $protocol''';
}