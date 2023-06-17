part of 'polo_server_helper.dart';

/// Use `Polo.createServer()` to Create a Standalone Server
class PoloServer {
  PoloServer._fromServer(HttpServer this._httpServer) {
    _server = _httpServer!.transform(WebSocketTransformer());
    _handleServer();
  }

  PoloServer._fromManager(this._server, this._onClose) {
    _httpServer = null;
    _handleServer();
  }
  late final HttpServer? _httpServer;
  late final Stream<WebSocket> _server;
  late final StreamSubscription<dynamic> _sub;

  void Function() _onClose = () {};

  final Map<String, PoloClient> _clients = {};

  final Map<String, PoloTypeAdapter<dynamic>> _registeredTypes = {};

  final List<PoloMiddleware> _middlewares = [];

  void Function(PoloClient client) _onConnectCallback = (client) {};
  void Function(String clientId, int? closeCode, String? closeReason)
      _onDisconnectCallback = (_, __, ___) {};

  /// Get all rooms
  Set<String> get rooms {
    final allRooms = <String>{};
    for (final client in _clients.values) {
      allRooms.addAll(client._rooms);
    }
    return allRooms;
  }

  /// Set OnConnect Callback
  set onClientConnect(void Function(PoloClient client) callback) {
    _onConnectCallback = callback;
  }

  /// Set OnDisconnect Callback
  set onClientDisconnect(
    void Function(String clientId, int? closeCode, String? closeReason)
        callback,
  ) {
    _onDisconnectCallback = callback;
  }

  void _onConnect(PoloClient client) {
    _clients[client.id] = client;
    mwCC(_middlewares, client.id);
    _onConnectCallback(client);
  }

  void _onDisconnect(PoloClient client) {
    client._onDisconnect = (clientId, closeCode, closeReason) {
      _clients.remove(clientId);
      _onDisconnectCallback(clientId, closeCode, closeReason);
    };
  }

  void _handleServer() {
    _sub = _server.asBroadcastStream().listen(_handleClient);
  }

  void _handleClient(WebSocket webSocket) {
    final client = PoloClient._(webSocket, _registeredTypes, _middlewares);
    // On Client Connected
    _onConnect(client);
    // On Client Disconnected
    _onDisconnect(client);
  }

  /// Sends message to all Clients
  void send<T>(String event, T data) {
    for (final client in _clients.values) {
      client.send<T>(event, data);
    }
  }

  /// Sends message to a Client by Id
  void sendToClient<T>(PoloClient client, String event, T data) {
    if (_clients.containsKey(client.id)) {
      _clients[client.id]!.send<T>(event, data);
    }
  }

  /// Sends message to a Room
  void sendToRoom<T>(String room, String event, T data) {
    for (final client in _clients.values) {
      if (client._rooms.contains(room)) {
        client.send<T>(event, data);
      }
    }
  }

  /// Broadcast from a Client to all other Clients
  void broadcastFrom<T>(PoloClient client, String event, T data) {
    for (final clientL in _clients.values) {
      if (clientL.id != client.id) {
        clientL.send<T>(event, data);
      }
    }
  }

  /// Broadcast from a Client to Room
  void broadcastToRoom<T>(
    PoloClient client,
    String room,
    String event,
    T data,
  ) {
    // Sender Client must join the Room to Broadcast
    if (!client._rooms.contains(room)) return;

    for (final clientL in _clients.values) {
      if (clientL.id != client.id && clientL._rooms.contains(room)) {
        clientL.send<T>(event, data);
      }
    }
  }

  /// Register a Type to the `PoloServer`
  void registerType<T>(PoloTypeAdapter<T> type) {
    final typeString = T.toString();
    _registeredTypes[typeString] = type;
  }

  /// Adds `PoloMiddleware` to the Server
  void addMiddleware(PoloMiddleware middleware) {
    _middlewares.add(middleware);
  }

  /// Closes the Server
  Future<void> close() async {
    if (_httpServer != null) {
      return _httpServer!.close(force: true);
    }

    await _sub.cancel();
    await Future.wait(_clients.values.map((e) => e.close()));
    _onClose();
  }
}
