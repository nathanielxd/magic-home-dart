library magic_home_api;

import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

class Light {

  Socket socket;

  Light(this.socket);

  void turnOn() {

    sendMessage([0x71, 0x23, 0x0f]);
  }

  void turnOff() {

    sendMessage([0x71, 0x24, 0x0f]);
  }

  static Future<Light> connect(dynamic ip) async {

    Socket soc = await Socket.connect(ip, 5577);
    return Light(soc);
  }
  

  void sendMessage(List<int> elements) {

    // Calculate CSUM
    int csum = 0;
    for(int i = 0; i < elements.length; i++) {
      csum += elements[i];
    } 
    csum = csum & 0xFF;
    elements.add(csum);
    
    //Create the message from the elements and send it
    var message = Uint8List.fromList(elements);

    socket.add(message);
    print(message);
  }
}