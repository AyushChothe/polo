part of 'polo_web_client_helper.dart';

/// Use `Polo.connect()` to Connect to the `PoloServer`
class PoloClient implements stub.PoloClient {
  late html.WebSocket _webSocket;

  final String url;

  final Map<String, Function> _callbacks = {};
  final Map<String, PoloTypeAdapter> _registeredTypes = {};

  void Function(int? closeCode, String? closeReason) _onDisconnectCallback =
      (_, __) {};

  void Function() _onConnectCallback = () {};

  @override
  String? get protocol => _webSocket.protocol;

  @override
  int get readyState => _webSocket.readyState;

  PoloClient._(this.url);

  /// Sets onConnectCallback
  @override
  void onConnect(void Function() callback) => _onConnectCallback = callback;

  /// Sets onDisconnectCallback
  @override
  void onDisconnect(
          void Function(int? closeCode, String? closeReason) callback) =>
      _onDisconnectCallback = callback;

  /// Adds a Callback to an Event
  @override
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
      };
    } else {
      _callbacks[event] = callback;
    }
  }

  void _emit(String event, dynamic data) {
    if (_callbacks.containsKey(event)) _callbacks[event]!(data);
  }

  /// Starts listening for messages from `PoloServer`
  @override
  Future<void> connect() {
    _webSocket = html.WebSocket(url);
    return _handleEvents();
  }

  /// Sends message to the Server from Client
  @override
  void send<T>(String event, T data) {
    String typeStr = T.toString();

    if (_registeredTypes.containsKey(typeStr)) {
      PoloTypeAdapter<T> typeAdapter =
          _registeredTypes[typeStr]! as PoloTypeAdapter<T>;
      _webSocket.sendString(
          jsonEncode({'event': event, 'data': typeAdapter.toMap(data)}));
    } else {
      _webSocket.sendString(jsonEncode({'event': event, 'data': data}));
    }
  }

  /// Register a Type to the `PoloClient`
  @override
  void registerType<T>(PoloTypeAdapter<T> type) {
    final typeString = T.toString();
    _registeredTypes[typeString] = type;
  }

  /// Closes the connection to the `PoloServer`
  @override
  Future<dynamic> close() async {
    return _webSocket.close();
  }

  Future<void> _handleEvents() async {
    _webSocket.onOpen.listen((event) => _onConnectCallback());
    _webSocket.onClose.listen((event) {
      _onDisconnectCallback(event.code, event.reason);
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
      close();
    }
  }
}
