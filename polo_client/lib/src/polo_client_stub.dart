abstract class PoloClient {
  final Map<String, void Function(dynamic)> _callbacks = {};

  void Function() _onDisconnectCallback = () {};
  void Function() _onConnectCallback = () {};

  /// Sets onConnectCallback
  void onConnect(void Function() callback) => _onConnectCallback = callback;

  /// Sets onDisconnectCallback
  void onDisconnect(void Function() callback) =>
      _onDisconnectCallback = callback;

  /// Adds a Callback to an Event
  void onEvent(String event, void Function(dynamic data) callback) =>
      _callbacks[event] = callback;

  void _emit(String event, dynamic data) =>
      _callbacks.containsKey(event) ? _callbacks[event]!(data) : () {};

  /// Starts listening for messages from `PoloServer`
  Future<void> listen() {
    return _handleEvents();
  }

  /// Sends message to the Server from Client
  void send(String event, dynamic data) {
    throw UnsupportedError("Platform is not Supported");
  }

  /// Closes the connection to the `PoloServer`
  Future<void> close() async {
    throw UnsupportedError("Platform is not Supported");
  }

  Future<void> _handleEvents() async {
    throw UnsupportedError("Platform is not Supported");
  }
}

abstract class Polo {
  /// Connects to the `PoloServer` and Returns the Instance of `PoloClient`
  static Future<PoloClient> connect(String url) async {
    throw UnsupportedError("Platform is not Supported");
  }
}
