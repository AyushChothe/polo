import 'polo_type.dart';

abstract class PoloClient {
  String? get protocol;
  int get readyState;

  /// Sets onConnectCallback
  void onConnect(void Function() callback) {
    throw UnsupportedError("Platform is not Supported");
  }

  /// Sets onDisconnectCallback
  void onDisconnect(
      void Function(int? closeCode, String? closeReason) callback) {
    throw UnsupportedError("Platform is not Supported");
  }

  /// Adds a Callback to an Event
  void onEvent<T>(String event, void Function(T data) callback) {
    throw UnsupportedError("Platform is not Supported");
  }

  /// Starts listening for messages from `PoloServer`
  Future<void> connect() {
    throw UnsupportedError("Platform is not Supported");
  }

  /// Sends message to the Server from Client
  void send<T>(String event, T data) {
    throw UnsupportedError("Platform is not Supported");
  }

  /// Register a custom Object as a Type with `PoloTypeAdapter`
  void registerType<T>(PoloTypeAdapter<T> type) {
    throw UnsupportedError("Platform is not Supported");
  }

  /// Closes the connection to the `PoloServer`
  Future<void> close() async {
    throw UnsupportedError("Platform is not Supported");
  }
}

abstract class Polo {
  /// Connects to the `PoloServer` and Returns the Instance of `PoloClient`
  static PoloClient connect(String url) {
    throw UnsupportedError("Platform is not Supported");
  }
}
