import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import './polo_client_stub.dart' as stub;
import 'polo_type.dart';

part 'polo_web_client_base.dart';

/// Creates an Instance of Polo Websocket Client (`PoloClient`)
class Polo implements stub.Polo {
  /// Connects to the `PoloServer` and Returns the Instance of `PoloClient`
  static Future<PoloClient> connect(String url) async {
    Completer ready = Completer();
    html.WebSocket client = html.WebSocket(url);
    client.onOpen.listen((event) {
      ready.complete();
    });
    await ready.future;

    return PoloClient._(client);
  }
}
