library magic_home;

import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'utilis.dart';
import 'dart:convert';
import 'dart:core';

class Light {

  Socket socket;

  bool isOn;
  String mode;
  RGB color;
  DateTime time;

  Light(this.socket) {

    _startListening();
  }

  Completer<List<int>> _data = Completer();

  /// Connects to the light of a certain IP and gets it's status
  static Future<Light> connect(String ip) async {

    Socket soc = await Socket.connect(ip, 5577);

    Light light = Light(soc);
    await light.getStatus();

    return light;
  }

  /// Sends a broadcast message to the LAN and decodes the responses, checking for any light.
  /// Then returns the detected light as a list of lights
  static Future<List<Light>> discover({Duration timeout = const Duration(seconds: 2), int port = 48899}) async {

    final List<int> MSG = utf8.encode('HF-A11ASSISTHREAD');

    List<Light> lights = new List<Light>();

    StreamSubscription<RawSocketEvent> subscription;
    Completer<List<Light>> completer = Completer();

    Timer(timeout,() {
      subscription.cancel();
      completer.complete(lights);
    });

    await RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((socket) {

      socket.broadcastEnabled = true;
      socket.send(MSG, InternetAddress("255.255.255.255"), port);

      subscription = socket.listen((e){

        Datagram data = socket.receive();
        var ip = _getAddress(data.data);
        if(ip != null) {

          print('Detected: $ip');
          Light.connect(ip).then((light){
            lights.add(light);
          });
        }   
      });
    });

  return completer.future;
  }

  void turnOn() {

    _sendMessage([0x71, 0x23, 0x0f]);
  }

  void turnOff() {

    _sendMessage([0x71, 0x24, 0x0f]);
  }

  /// Set the color by RGB values from 0 to 255
  void setColor(int red, int green, int blue) {

    _sendMessage([0x31, red, green, blue, 0x00, 0x00, 0x0f]);
  }

  void setColorByRGB(RGB color) {

    _sendMessage([0x31, color.red, color.green, color.blue, 0x00, 0x00, 0x0f]);
  }

  /// Sets a preset pattern which can be identified by PresetPattern class
  /// and a speed from 1 to 100
  void setPresetPattern(int pattern, int speed) {

    _sendMessage([0x61, pattern, Utilis.speedToDelay(speed), 0x0f]);
  }

  /// Set a custom pattern from a list of RGBs,
  /// a transition type which can be identified by TransitionType class
  /// and speed from 1 to 100
  void setCustomPattern(List<RGB> colors, int transitionType, int speed) {

    List<int> message = List<int>();
    message.add(0x51);

    if(colors.isNotEmpty) {
      message.addAll([colors[0].red, colors[0].green, colors[0].blue]);
    }

    for(int i = 1; i < colors.length; i++) {
      message.add(0);
      message.addAll([colors[i].red, colors[i].green, colors[i].blue]);
    }

    for(int i = 0; i < 16 - colors.length; i++) {
      message.addAll([0, 1, 2, 3]);
    }

    message.addAll([0x00, Utilis.speedToDelay(speed), transitionType, 0xff, 0x0f]);

    _sendMessage(message);
  }

  /// Sends a message to the bulb then decodes the response,
  /// getting the light's status, mode, color, time
  /// This method is automatically called when connecting
  void getStatus() async {

    _sendMessage([0x81, 0x8a, 0x8b]);
    List<String> hexData = await _readMessageAsHex();

    _sendMessage([0x81, 0x8a, 0x8b]);
    List<int> byteData = await _readMessageAsBytes();

    print(byteData);
    print(hexData);

    if(hexData[2] == '23') {
      isOn = true;
    }

    mode = Utilis.determineMode(hexData[3]);

    if(mode == 'Color') {
      color = RGB(byteData[6], byteData[7], byteData[8]);
    }

    time = await _getTime();
  }

  Future<DateTime> _getTime() {

    Completer<DateTime> dateTime = Completer();

    _sendMessage([0x11, 0x1a, 0x1b, 0x0f]);

    _readMessageAsBytes().then((data){
      dateTime.complete(
        DateTime(
          data[3] + 2000,
          data[4],
          data[5],
          data[6],
          data[7],
          data[8]
        )
      );
    });

    return dateTime.future;
  }
  
  static String _getAddress(List<int> dataInt) {

    String lightAddress;

    var data = String.fromCharCodes(dataInt);
    List<String> dataList = data.split(',');
    if(dataList.length > 1) {
      lightAddress = dataList[0];
    }

    return lightAddress;
  }

  Future<List<String>> _readMessageAsHex() {

    List<String> hexData = List();
    Completer<List<String>> hexDataCompleter = Completer();

    _data.future.then((data){
      data.forEach((byte){
        hexData.add(byte.toRadixString(16));
      });
      hexDataCompleter.complete(hexData);
    });

    return hexDataCompleter.future;
  }

  Future<List<int>> _readMessageAsBytes() {

    return _data.future;
  }

  void _startListening() {

    socket.listen((data){
      _data.complete(data);
      _data = Completer();
    });
  }

  void _sendMessage(List<int> bytes) {

    // Calculate CSUM
    int csum = 0;
    for(int i = 0; i < bytes.length; i++) {
      csum += bytes[i];
    } 
    csum = csum & 0xFF;
    bytes.add(csum);
    
    //Create the message from the byte list and send it
    var message = Uint8List.fromList(bytes);

    socket.add(message);
  }
}

class PresetPattern {

  static const SevenColorsCrossFade = 0x25;
  static const RedGradualChange = 0x26;
  static const GreenGradualChange = 0x27;
  static const BlueGradualChange = 0x28;
  static const YellowGradualChange = 0x29;
  static const CyanGradualChange = 0x2a;
  static const PurpleGradualChange = 0x2b;
  static const WhiteGradualChange = 0x2c;
  static const RedGreenCrossFade = 0x2d;
  static const RedBlueCrossFade = 0x2e;
  static const GreenBlueCrossFade = 0x2f;
  static const SevenColorStrobeFlash = 0x30;
  static const RedStrobeFlash = 0x31;
  static const GreenStrobeFlash = 0x32;
  static const BlueStrobeFlash = 0x33;
  static const YellowStrobeFlash = 0x34;
  static const CyanStrobeFlash = 0x35;
  static const PurpleStrobeFlash = 0x36;
  static const WhiteStrobeFlash = 0x37;
  static const SevenColorsJumping = 0x38;
}

class TransitionType {
  
  static const Gradual = 0x3a;
  static const Jump = 0x3b;
  static const Strobe = 0x3c;
}

class RGB {

  int red;
  int green;
  int blue;

  RGB([this.red = 0, this.green = 0, this.blue = 0]);
}