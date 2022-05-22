part of 'polo_server_helper.dart';

class PoloClient {
  final WebSocket webSocket;
  late final String id;
  Map<String, void Function(dynamic)> callbacks = {};
  final Set<String> _rooms = {};

  void Function(PoloClient) _onDisconnectCallback = (poloClient) {};

  PoloClient._(this.webSocket) {
    id = Uuid().v4();
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
    webSocket.add(jsonEncode({'event': event, 'data': data}).codeUnits);
  }

  /// Joins a Room
  void joinRoom(String room) {
    _rooms.add(room.trim());
  }

  /// Leaves a Room
  void leaveRoom(String room) {
    _rooms.remove(room.trim());
  }

  Future<void> close() async {
    return webSocket.close();
  }

  void _handleEvents() async {
    webSocket.done.then((_) {
      // emit('disconnect', this);
      _onDisconnectCallback(this);
    });
    onEvent("message", (message) => print(message.toString()));
    try {
      //Listen for Messages from Client
      await for (dynamic message in webSocket) {
        if (message is String) {
          _emit("message", message);
        } else if (message is List<int>) {
          final Map<String, dynamic> msg =
              jsonDecode(String.fromCharCodes(message));
          _emit(msg['event'], msg['data']);
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      webSocket.close();
    }
  }
}
