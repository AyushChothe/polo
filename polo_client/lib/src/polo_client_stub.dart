import 'polo_type.dart';

abstract class PoloClient {
  /// Sets onConnectCallback
  void onConnect(void Function() callback) {
    throw UnsupportedError("Platform is not Supported");
  }

  /// Sets onDisconnectCallback
  void onDisconnect(void Function() callback) {
    throw UnsupportedError("Platform is not Supported");
  }

  /// Adds a Callback to an Event
  void onEvent<T>(String event, void Function(T data) callback,
      {PoloType? converter}) {
    throw UnsupportedError("Platform is not Supported");
  }

  /// Starts listening for messages from `PoloServer`
  Future<void> listen() {
    throw UnsupportedError("Platform is not Supported");
  }

  /// Sends message to the Server from Client
  void send<T>(String event, T data) {
    throw UnsupportedError("Platform is not Supported");
  }

  /// Closes the connection to the `PoloServer`
  Future<void> close() async {
    throw UnsupportedError("Platform is not Supported");
  }
}

abstract class Polo {
  /// Connects to the `PoloServer` and Returns the Instance of `PoloClient`
  static Future<PoloClient> connect(String url) async {
    throw UnsupportedError("Platform is not Supported");
  }
}
