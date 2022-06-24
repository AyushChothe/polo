part of 'polo_server_helper.dart';

/// `PoloClient` is used to handle Connected WebSocket
class PoloClient {
  final WebSocket _webSocket;

  late final String _id;
  String get id => _id;

  String? get protocol => _webSocket.protocol;

  int get readyState => _webSocket.readyState;

  final Map<String, Function> _callbacks = {};
  final Map<String, PoloTypeAdapter> _registeredTypes;
  final List<PoloMiddleware> _middlewares;
  final Set<String> _rooms = {};

  void Function(String clientId, int? closeCode, String? closeReason)
      _onDisconnectCallback = (_, __, ___) {};

  PoloClient._(this._webSocket, this._registeredTypes, this._middlewares) {
    _id = Uuid().v4();
    _handleEvents();
  }

  void _onDisconnect(
          void Function(String clientId, int? closeCode, String? closeReason)
              callback) =>
      _onDisconnectCallback = callback;

  /// Adds a Callback to an Event
  void onEvent<T>(
    String event,
    void Function(T data) callback,
  ) {
    String typeStr = T.toString();
    if (_registeredTypes.containsKey(typeStr)) {
      _callbacks[event] = (Map<String, dynamic> data) {
        PoloTypeAdapter<T> typeAdapter =
            _registeredTypes[typeStr]! as PoloTypeAdapter<T>;
        T typedData = typeAdapter.fromMap(data);
        callback(typedData);
        mwCTS<T>(_middlewares, id, event, typedData);
      };
    } else {
      _callbacks[event] = (data) {
        callback(data);
        mwCTS(_middlewares, id, event, data);
      };
    }
  }

  void _emit(String event, dynamic data) {
    if (_callbacks.containsKey(event)) _callbacks[event]!(data);
  }

  /// Sends message to the Client from Server
  void send<T>(String event, T data) {
    String typeStr = T.toString();

    if (_registeredTypes.containsKey(typeStr)) {
      PoloTypeAdapter<T> typeAdapter =
          _registeredTypes[typeStr]! as PoloTypeAdapter<T>;
      Map<String, dynamic> mapData = typeAdapter.toMap(data);
      _webSocket.add(jsonEncode({'event': event, 'data': mapData}));
      mwSTC(_middlewares, id, event, mapData);
    } else {
      _webSocket.add(jsonEncode({'event': event, 'data': data}));
      mwSTC(_middlewares, id, event, data);
    }
  }

  /// Joins a Room
  void joinRoom(String room) {
    _rooms.add(room.trim());
    mwJR(_middlewares, id, room);
  }

  /// Leaves a Room
  void leaveRoom(String room) {
    _rooms.remove(room.trim());
    mwLR(_middlewares, id, room);
  }

  /// Closes the Client
  Future<dynamic> close() async {
    return _webSocket.close();
  }

  Future<void> _handleEvents() async {
    _webSocket.done.then((_) {
      _onDisconnectCallback(id, _webSocket.closeCode, _webSocket.closeReason);
      mwCD(_middlewares, id, _webSocket.closeCode, _webSocket.closeReason);
    });
    try {
      //Listen for Messages from Client
      await for (dynamic message in _webSocket) {
        final Map<String, dynamic> msg = jsonDecode(message);
        _emit(msg['event'], msg['data']);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      close();
    }
  }
}
