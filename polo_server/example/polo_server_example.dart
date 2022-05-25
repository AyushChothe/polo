import 'package:polo_server/polo_server.dart';

void main() async {
  // Manager
  // Polo polo = await Polo.createManager();
  // PoloServer server = polo.of('/chat');

  // Direct Server
  PoloServer server = await Polo.createServer();

  server.onClientConnect((client) {
    print("Client(${client.id}) Connected!");

    client.onEvent('message',
        (message) => server.broadcastFrom(client.id, 'message', message));
  });

  server.onClientDisconnect((client) {
    print("Client(${client.id}) Disconnected!");
  });

  print("Server Running...");
}
