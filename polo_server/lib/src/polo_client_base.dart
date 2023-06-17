part of 'polo_server_helper.dart';

/// `PoloClient` is used to handle Connected WebSocket
class PoloClient {
  PoloClient._(this._webSocket, this._registeredTypes, this._middlewares) {
    _id = const Uuid().v4();
    _handleEvents();
  }
  final WebSocket _webSocket;

  late final String _id;
  String get id => _id;

  String? get protocol => _webSocket.protocol;

  int get readyState => _webSocket.readyState;

  final Map<String, Function> _callbacks = {};
  final Map<String, PoloTypeAdapter<dynamic>> _registeredTypes;
  final List<PoloMiddleware> _middlewares;
  final Set<String> _rooms = {};

  void Function(String clientId, int? closeCode, String? closeReason)
      _onDisconnectCallback = (_, __, ___) {};

  set _onDisconnect(
    void Function(String clientId, int? closeCode, String? closeReason)
        callback,
  ) =>
      _onDisconnectCallback = callback;

  /// Adds a Callback to an Event
  void onEvent<T>(
    String event,
    void Function(T data) callback,
  ) {
    final typeStr = T.toString();
    if (_registeredTypes.containsKey(typeStr)) {
      _callbacks[event] = (Map<String, dynamic> data) {
        final typeAdapter = _registeredTypes[typeStr]! as PoloTypeAdapter<T>;
        final typedData = typeAdapter.fromMap(data);
        callback(typedData);
        mwCTS<T>(_middlewares, id, event, typedData);
      };
    } else {
      _callbacks[event] = (T data) {
        callback(data);
        mwCTS(_middlewares, id, event, data);
      };
    }
  }

  void _emit(String event, dynamic data) {
    // ignore: avoid_dynamic_calls
    if (_callbacks.containsKey(event)) _callbacks[event]!(data);
  }

  /// Sends message to the Client from Server
  void send<T>(String event, T data) {
    final typeStr = T.toString();

    if (_registeredTypes.containsKey(typeStr)) {
      final typeAdapter = _registeredTypes[typeStr]! as PoloTypeAdapter<T>;
      final mapData = typeAdapter.toMap(data);
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
    await _webSocket.done.then((_) {
      _onDisconnectCallback(id, _webSocket.closeCode, _webSocket.closeReason);
      mwCD(_middlewares, id, _webSocket.closeCode, _webSocket.closeReason);
    });
    try {
      //Listen for Messages from Client
      await for (final message in _webSocket) {
        final msg = jsonDecode(message.toString()) as Map<String, dynamic>;
        _emit(msg['event'] as String, msg['data']);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      await close();
    }
  }
}
