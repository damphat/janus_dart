import 'dart:async';

import 'package:janus_dart/janus.dart';

class Session {
  final Janus _j;
  final int _id;
  Timer _timer;

  Session(this._j, this._id) {
    _timer = Timer.periodic(Duration(seconds: 20), (_) async {
      var res = await call({'janus': 'keepalive'});
      print(" =>${res['janus']}");
    });
  }

  call(Map<String, dynamic> req) {
    req['session_id'] = _id;
    return this._j.call(req);
  }

  attachPlugin(String plugin) {
    return this.call({'janus': 'attach', 'plugin': plugin});
  }
}
