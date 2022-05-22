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

    server.sendToClient(client.id, 'message', 'Welcome ${client.id}');
  });

  server.onClientDisconnect((client) {
    print("Client(${client.id}) Disconnected!");
  });

  // Timer.periodic(Duration(seconds: 5), (timer) {
  //   server.send('message', "Ping from Server...");
  // });

  print("Server Running...");

  await server.close();

  print("Server Close");
}
