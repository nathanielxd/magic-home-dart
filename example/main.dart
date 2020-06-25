import '../lib/magic_home.dart';

main() async {
  var lights = await LightDiscovery.discover();

  var light = lights[0];
  await light.connect();

  if(!light.power){
    await light.turnOn();
  }

  await light.setCustomPattern([
    Color(255, 0, 0), Color.cyan, Color.orange
  ], TransitionType.Gradual, 70);
}