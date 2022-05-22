part of 'polo_server_helper.dart';

/// Use `Polo.createServer()` to Create a Standalone Server
class PoloServer {
  late final HttpServer? _httpServer;
  late final Stream<WebSocket> _server;
  late final StreamSubscription _sub;

  void Function() _onClose = () {};

  Map<String, PoloClient> clients = {};

  void Function(PoloClient client) _onConnectCallback = (client) {};
  void Function(PoloClient client) _onDisconnectCallback = (client) {};

  PoloServer._fromServer(this._httpServer) {
    assert(_httpServer != null);
    _server = _httpServer!.transform(WebSocketTransformer());
    _handleServer();
  }

  PoloServer._fromManager(this._server, this._onClose) {
    _httpServer = null;
    _handleServer();
  }

  /// Get all rooms
  Set<String> get rooms {
    Set<String> allRooms = {};
    for (PoloClient client in clients.values) {
      allRooms.addAll(client._rooms);
    }
    return allRooms;
  }

  /// Set OnConnect Callback
  void onClientConnect(void Function(PoloClient client) callback) {
    _onConnectCallback = callback;
  }

  /// Set OnDisconnect Callback
  void onClientDisconnect(void Function(PoloClient client) callback) {
    _onDisconnectCallback = callback;
  }

  void _onConnect(PoloClient client) {
    clients[client.id] = client;
    _onConnectCallback(client);
  }

  void _onDisconnect(PoloClient client) {
    client._onDisconnect((client) {
      clients.remove(client.id);
      _onDisconnectCallback(client);
    });
  }

  void _handleServer() async {
    _sub = _server.listen((webSocket) {
      _handleClient(webSocket);
    });
  }

  void _handleClient(WebSocket webSocket) {
    PoloClient client = PoloClient._(webSocket);
    // On Client Connected
    _onConnect(client);
    // On Client Disconnected
    _onDisconnect(client);
  }

  /// Sends message to all Clients
  void send(String event, dynamic message) {
    for (PoloClient client in clients.values) {
      client.send(event, message);
    }
  }

  /// Sends message to a Client by Id
  void sendToClient(String clientId, String event, dynamic message) {
    if (clients.containsKey(clientId)) {
      clients[clientId]!.send(event, message);
    }
  }

  void sendToRoom(String room, String event, dynamic message) {
    for (PoloClient client in clients.values) {
      if (client._rooms.contains(room)) {
        client.send(event, message);
      }
    }
  }

  Future<void> close() async {
    if (_httpServer != null) {
      return _httpServer!.close(force: true);
    }

    await _sub.cancel();
    await Future.wait(clients.values.map((e) => e.close()));
    _onClose();
  }
}
