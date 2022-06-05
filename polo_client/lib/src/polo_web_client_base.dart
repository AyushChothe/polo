part of 'polo_web_client_helper.dart';

/// Use `Polo.connect()` to Connect to the `PoloServer`
class PoloClient implements stub.PoloClient {
  final html.WebSocket _webSocket;
  final Map<String, void Function(dynamic)> _callbacks = {};

  void Function() _onDisconnectCallback = () {};
  void Function() _onConnectCallback = () {};

  PoloClient._(this._webSocket);

  /// Sets onConnectCallback
  @override
  void onConnect(void Function() callback) => _onConnectCallback = callback;

  /// Sets onDisconnectCallback
  @override
  void onDisconnect(void Function() callback) =>
      _onDisconnectCallback = callback;

  /// Adds a Callback to an Event
  @override
  void onEvent(String event, void Function(dynamic data) callback) =>
      _callbacks[event] = callback;

  void _emit(String event, dynamic data) =>
      _callbacks.containsKey(event) ? _callbacks[event]!(data) : () {};

  /// Starts listening for messages from `PoloServer`
  @override
  Future<void> listen() {
    return _handleEvents();
  }

  /// Sends message to the Server from Client
  @override
  void send(String event, dynamic data) {
    _webSocket.sendString(jsonEncode({'event': event, 'data': data}));
  }

  /// Closes the connection to the `PoloServer`
  @override
  Future<dynamic> close() async {
    return _webSocket.close();
  }

  Future<void> _handleEvents() async {
    _onConnectCallback();
    _webSocket.onClose.listen((event) {
      _onDisconnectCallback();
    });
    try {
      //Listen for Messages from Server
      await for (html.MessageEvent message in _webSocket.onMessage) {
        final Map<String, dynamic> msg = jsonDecode(message.data);
        _emit(msg['event'], msg['data']);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      _webSocket.close();
    }
  }
}
