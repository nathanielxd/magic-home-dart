import 'package:magic_home_api/magic_home_api.dart';

main() {

  Light.connect('192.168.1.4').then((light) {
    light.turnOn();
  });
}