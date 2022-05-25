import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

part 'polo_web_client_base.dart';

/// Creates an Instance of Polo Websocket Client (`PoloWebClient`)
class PoloWeb {
  /// Connects to the `PoloServer` and Returns the Instance of `PoloWebClient`
  static Future<PoloWebClient> connect(String url) async {
    Completer ready = Completer();
    html.WebSocket client = html.WebSocket(url);
    client.onOpen.listen((event) {
      ready.complete();
    });
    await ready.future;

    return PoloWebClient._(client);
  }
}
