import 'package:janus_dart/janus.dart';

void main() async {
  var j = await Janus.connect('https://janus.damphat.com:8089/wss');
  var session = await j.createSession();
  var echo = await session.attachPlugin('janus.plugin.echotest');
}
