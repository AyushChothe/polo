part of 'polo_client_helper.dart';

/// Use `Polo.connect()` to Connect to the `PoloServer`
class PoloClient {
  final WebSocket webSocket;
  Map<String, void Function(dynamic)> callbacks = {};

  void Function() _onDisconnectCallback = () {};
  void Function() _onConnectCallback = () {};

  PoloClient._(this.webSocket);

  /// Sets onConnectCallback
  void onConnect(void Function() callback) => _onConnectCallback = callback;

  /// Sets onDisconnectCallback
  void onDisconnect(void Function() callback) =>
      _onDisconnectCallback = callback;

  /// Adds a Callback to an Event
  void onEvent(String event, void Function(dynamic data) callback) =>
      callbacks[event] = callback;

  void _emit(String event, dynamic data) =>
      callbacks.containsKey(event) ? callbacks[event]!(data) : () {};

  /// Starts listening for messages from `PoloServer`
  Future<void> listen() {
    return _handleEvents();
  }

  /// Sends message to the Server from Client
  void send(String event, dynamic data) {
    webSocket.add(jsonEncode({'event': event, 'data': data}).codeUnits);
  }

  /// Closes the connection to the `PoloServer`
  Future<void> close() async {
    return webSocket.close();
  }

  Future<void> _handleEvents() async {
    _onConnectCallback();
    webSocket.done.then((_) {
      _onDisconnectCallback();
    });
    try {
      //Listen for Messages from Server
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
