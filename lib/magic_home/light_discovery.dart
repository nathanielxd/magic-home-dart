part of magic_home;

/// Class used to discover lights on the network.
class LightDiscovery {

  /// How long will the socket listen to responses in milliseconds.
  static int timeout = 1000;

  // Constants
  static String _discovery_message = 'HF-A11ASSISTHREAD';
  static int _port = 48899;

  /// Send a broadcast message on the LAN to get all available lights.
  /// This operation will take 1 second by default. You can modify the timeout property to change the execution time.
  static Future<List<Light>> discover() async {
    
    List<Light> lights = new List<Light>();

    StreamSubscription<RawSocketEvent> subscription;
    Completer<List<Light>> completer = Completer();

    // After timeout, close connection and complete completer.
    Timer(Duration(milliseconds: timeout), () {
      subscription.cancel();
      completer.complete(lights);
    });

    await RawDatagramSocket.bind(InternetAddress.anyIPv4, _port).then((socket) {
      // Send broadcast message to LAN.
      socket.broadcastEnabled = true;
      socket.send(utf8.encode(_discovery_message), InternetAddress("255.255.255.255"), _port);

      // Start listening.
      subscription = socket.listen((e){
        // Receive and decode data.
        Datagram data = socket.receive();
        var response = String.fromCharCodes(data.data);
        if(response != _discovery_message){
          var ip = response.split(',')[0];
          lights.add(Light(ip));
        }
      });
    });

  return completer.future;
  }
}