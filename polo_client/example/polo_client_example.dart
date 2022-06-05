import 'package:polo_client/polo_client.dart';

void main() async {
  // Polo Client
  PoloClient client = await Polo.connect("ws://127.0.0.1:3000/chat");

  client.onConnect(() {
    print("Client Connected to Server");
  });

  client.onDisconnect(() {
    print("Client Disconnected from Server");
  });

  client.onEvent('message', (message) {
    print("$message");
  });

  client.listen();
}
