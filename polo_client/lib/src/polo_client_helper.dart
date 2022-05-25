import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

part 'polo_client_base.dart';

/// Creates an Instance of Polo Websocket Client (`PoloClient`)
class Polo {
  /// Connects to the `PoloServer` and Returns the Instance of `PoloClient`
  static Future<PoloClient> connect(String url) async {
    io.WebSocket client = await io.WebSocket.connect(url);
    return PoloClient._(client);
  }
}
