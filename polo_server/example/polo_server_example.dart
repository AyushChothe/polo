import 'package:polo_server/polo_server.dart';

void main() async {
  // Manager
  // Polo polo = await Polo.createManager();
  // PoloServer server = polo.root;

  // Direct Server
  PoloServer server = await Polo.createServer();

  server.onClientConnect((client) {
    print("Client(${client.id}) Connected!");

    client.onEvent('message',
        (message) => print("Message from Client(${client.id}): $message"));

    client.onEvent('userJoined',
        (data) => print("UserJoined(${client.id}): ${data.toString()}"));

    client.send('message', "Hi From Server!");
  });

  server.onClientDisconnect((client) {
    print("Client(${client.id}) Disconnected!");
  });

  print("Server Running...");
}
