import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

part 'polo_client_base.dart';
part 'polo_server_base.dart';

/// Creates an Instance of Polo Websocket Server (`PoloServer`)
class Polo {
  late final HttpServer _httpServer;
  final Map<String, PoloServer> _namespaces = {};

  Polo._(this._httpServer);

  /// Creates a Polo Manager to handle multiple `PoloServer`'s
  static Future<Polo> createManager(
      {String address = "127.0.0.1", int port = 3000}) async {
    final httpServer = (await HttpServer.bind(address, port));
    return Polo._(httpServer);
  }

  /// Creates a Standalone `PoloServer`
  static Future<PoloServer> createServer(
      {String address = "127.0.0.1", int port = 3000}) async {
    final httpServer = (await HttpServer.bind(address, port));
    return PoloServer._fromServer(httpServer);
  }

  /// Returns the Instance of `PoloServer` associated with the `/` Namespace
  PoloServer get root => of('/');

  /// Returns the Instance of `PoloServer` associated with the Namespace
  /// or Creates the Instance if not present
  PoloServer of(String namespace) {
    if (!_namespaces.containsKey(namespace)) {
      Stream<WebSocket> socketStream = _httpServer
          .where((req) => req.uri.path == namespace)
          .transform(WebSocketTransformer());
      _namespaces[namespace] = PoloServer._fromManager(
          socketStream, (() => _namespaces.remove(namespace)));
    }
    return _namespaces[namespace]!;
  }

  /// Closes all `PoloServer`'s of `Polo`
  Future<void> close() async {
    _httpServer.close(force: true);
  }
}
