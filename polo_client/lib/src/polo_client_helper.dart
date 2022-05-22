import 'dart:convert';
import 'dart:io';

part 'polo_client_base.dart';

/// Creates an Instance of Polo Websocket Client (`PoloClient`)
class Polo {
  /// Connects to the `PoloServer` and Returns the Instance of `PoloClient`
  static Future<PoloClient> connect(String url) async {
    WebSocket client = await WebSocket.connect(url);
    return PoloClient._(client);
  }
}
