import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:polo_server/src/polo_middleware.dart';
import 'package:polo_server/src/polo_type.dart';
import 'package:uuid/uuid.dart';

part 'polo_client_base.dart';
part 'polo_server_base.dart';

/// Creates an Instance of Polo Websocket Server (`PoloServer`)
class Polo {
  Polo._(this._httpServer, this._dashboardNamespace) {
    reqStream = _httpServer.asBroadcastStream();
    _dashboard();
  }
  late final HttpServer _httpServer;
  late Stream<HttpRequest> reqStream;
  final Map<String, PoloServer> _namespaces = {};

  final String? _dashboardNamespace;

  /// Creates a Polo Manager to handle multiple `PoloServer`'s
  static Future<Polo> createManager({
    String address = '127.0.0.1',
    int port = 3000,
    String? dashboardNamespace,
  }) async {
    final httpServer = await HttpServer.bind(address, port);
    return Polo._(httpServer, dashboardNamespace);
  }

  /// Creates a Standalone `PoloServer`
  static Future<PoloServer> createServer({
    String address = '127.0.0.1',
    int port = 3000,
  }) async {
    final httpServer = await HttpServer.bind(address, port);
    return PoloServer._fromServer(httpServer);
  }

  void _dashboard() {
    if (_dashboardNamespace == null) return;
    final ps = of(_dashboardNamespace!);

    List<Map<String, dynamic>> res() => [
          for (final ns in _namespaces.entries)
            {
              'ns': ns.key,
              'rooms': ns.value.rooms.toList(),
              'clients': ns.value._clients.values.map((c) {
                return {
                  'id': c.id,
                  'rooms': c._rooms.toList(),
                  'events': c._callbacks.keys.toList(),
                };
              }).toList(),
            }
        ];

    ps.onClientConnect = (client) {
      final ping = Timer.periodic(const Duration(seconds: 1), (_) {
        client.send<List<dynamic>>('polo:dashboard:get', res());
      });
      ps.onClientDisconnect = (clientId, closeCode, closeReason) {
        ping.cancel();
        print('Disconnected from Dashboard (${client.id})');
      };
      print('Connected to Dashboard (${client.id})');
    };
  }

  /// or Creates the Instance if not present
  PoloServer of(String namespace) {
    assert(
      !(_namespaces.containsKey(_dashboardNamespace) &&
          namespace == _dashboardNamespace),
      'Dashboard is Enabled',
    );
    if (!_namespaces.containsKey(namespace)) {
      final socketStream = reqStream
          .where((req) => req.uri.path == namespace)
          .transform(WebSocketTransformer());
      _namespaces[namespace] = PoloServer._fromManager(
        socketStream,
        () => _namespaces.remove(namespace),
      );
    }
    return _namespaces[namespace]!;
  }

  bool hasNamespace(String namespace) => _namespaces.containsKey(namespace);

  /// Closes all `PoloServer`'s of `Polo`
  Future<void> close() async {
    await _httpServer.close(force: true);
  }
}
