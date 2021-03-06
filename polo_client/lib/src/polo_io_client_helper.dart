import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import './polo_client_stub.dart' as stub;
import 'polo_type.dart';

part 'polo_io_client_base.dart';

/// Creates an Instance of Polo Websocket Client (`PoloClient`)
class Polo implements stub.Polo {
  /// Connects to the `PoloServer` and Returns the Instance of `PoloClient`
  static PoloClient createClient(String url) {
    return PoloClient._(url);
  }
}
