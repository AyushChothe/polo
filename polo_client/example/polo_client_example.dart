import 'package:polo_client/polo_client.dart';

void main() async {
  //Polo Client
  PoloClient client = await Polo.connect("ws://127.0.0.1:3000/");

  client.onConnect(() {
    print("Client Connected to Server");
    client.send('message', "Hi from Client");
    client.send('userJoined', {
      "name": "Ayush",
      "age": 22,
      "isMale": true,
    });
  });

  client.onDisconnect(() {
    print("Client Disconnected from Server");
  });

  client.onEvent('message', (message) {
    print("Message from Server: $message");
  });

  await client.listen();
}
