import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:janus_dart/session.dart';
import 'package:janus_dart/utils.dart';

class Janus {
  final WebSocket _ws;
  final Stream _stream;
  final Map<String, Completer<Map<String, dynamic>>> _trans = {};

  Janus._(this._ws) : _stream = _ws.asBroadcastStream() {
    _stream.listen((event) {
      Map<String, dynamic> res = jsonDecode(event.toString());
      print('res = $res');
      if (res.containsKey('transaction')) {
        var t = res['transaction'];
        if (_trans.containsKey(t)) {
          var c = _trans[t];
          _trans.remove(t);
          c.complete(res);
          print('  complete $t');
        } else {
          print('  unknown transaction $t');
        }
      }
    });
  }

  Future<Map<String, dynamic>> call(Map<String, dynamic> req) {
    var id = uid();
    var completer = Completer<Map<String, dynamic>>();
    _trans[id] = completer;

    req['transaction'] = id;
    _ws.add(jsonEncode(req));

    print('call $req');
    return completer.future;
  }

  Future<Session> createSession() async {
    var res = await call({'janus': 'create'});
    return Session(this, res['data']['id']);
  }

  static String normalizeScheme(String scheme) {
    switch (scheme) {
      case 'http':
      case 'ws':
        return 'ws';
      default:
        return 'wss';
    }
  }

  static String normalizeUrl(String url) {
    var uri = Uri.parse(url);
    return '${normalizeScheme(uri.scheme)}://${uri.authority}/ws';
  }

  static Future<Janus> connect(String url) async {
    url = normalizeUrl(url);
    var ws = await WebSocket.connect(url, protocols: ['janus-protocol']);
    return Janus._(ws);
  }
}
