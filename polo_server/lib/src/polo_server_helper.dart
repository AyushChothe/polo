import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:polo_server/src/polo_type.dart';
import 'package:uuid/uuid.dart';

part 'polo_client_base.dart';
part 'polo_server_base.dart';

/// Creates an Instance of Polo Websocket Server (`PoloServer`)
class Polo {
  late final HttpServer _httpServer;
  late Stream<HttpRequest> reqStream;
  final Map<String, PoloServer> _namespaces = {};

  final String? _dashboardNamespace;
  Polo._(this._httpServer, this._dashboardNamespace) {
    reqStream = _httpServer.asBroadcastStream();
    _dashboard();
  }

  /// Creates a Polo Manager to handle multiple `PoloServer`'s
  static Future<Polo> createManager({
    String address = "127.0.0.1",
    int port = 3000,
    String? dashboardNamespace,
  }) async {
    final httpServer = (await HttpServer.bind(address, port));
    return Polo._(httpServer, dashboardNamespace);
  }

  /// Creates a Standalone `PoloServer`
  static Future<PoloServer> createServer(
      {String address = "127.0.0.1", int port = 3000}) async {
    final httpServer = (await HttpServer.bind(address, port));
    return PoloServer._fromServer(httpServer);
  }

  void _dashboard() {
    if (_dashboardNamespace == null) return;
    PoloServer ps = of(_dashboardNamespace!);
    ps.onClientConnect((client) {
      client.onEvent('polo:dashboard:get_servers', (data) {});
      client.onEvent('polo:dashboard:get_server', (data) {});
      client.onEvent('polo:dashboard:get_clients', (data) {});
      client.onEvent('polo:dashboard:get_events', (data) {});
      client.onEvent('polo:dashboard:get_events', (data) {});
    });
  }

  /// or Creates the Instance if not present
  PoloServer of(String namespace) {
    assert(
        !(_namespaces.containsKey(_dashboardNamespace) &&
            namespace == _dashboardNamespace),
        "Dashboard is Enabled");
    if (!_namespaces.containsKey(namespace)) {
      Stream<WebSocket> socketStream = reqStream
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
