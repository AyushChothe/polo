part of 'polo_server_helper.dart';

/// `PoloClient` is used to handle Connected WebSocket
class PoloClient {
  final WebSocket _webSocket;
  late final String _id;
  String get id => _id;
  Map<String, void Function(dynamic)> callbacks = {};
  final Set<String> _rooms = {};

  void Function(PoloClient) _onDisconnectCallback = (poloClient) {};

  PoloClient._(this._webSocket) {
    _id = Uuid().v4();
    _handleEvents();
  }

  void _onDisconnect(void Function(PoloClient) callback) =>
      _onDisconnectCallback = callback;

  /// Adds a Callback to an Event
  void onEvent(String event, void Function(dynamic data) callback) =>
      callbacks[event] = callback;

  void _emit(String event, dynamic data) =>
      callbacks.containsKey(event) ? callbacks[event]!(data) : () {};

  /// Sends message to the Client from Server
  void send(String event, dynamic data) {
    _webSocket.add(jsonEncode({'event': event, 'data': data}));
  }

  /// Joins a Room
  void joinRoom(String room) {
    _rooms.add(room.trim());
  }

  /// Leaves a Room
  void leaveRoom(String room) {
    _rooms.remove(room.trim());
  }

  /// Closes the Client
  Future<void> close() async {
    return _webSocket.close();
  }

  void _handleEvents() async {
    _webSocket.done.then((_) {
      // emit('disconnect', this);
      _onDisconnectCallback(this);
    });
    onEvent("message", (message) => print(message.toString()));
    try {
      //Listen for Messages from Client
      await for (dynamic message in _webSocket) {
        final Map<String, dynamic> msg = jsonDecode(message);
        _emit(msg['event'], msg['data']);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      _webSocket.close();
    }
  }
}
