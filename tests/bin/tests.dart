import 'package:polo_client/polo_client.dart' as pc;
import 'package:polo_server/polo_server.dart' as ps;

void main(List<String> args) async {
  ps.PoloServer server =
      await ps.Polo.createServer(address: "127.0.0.1", port: 3000);
  pc.PoloClient client = pc.Polo.createClient("ws://127.0.0.1:3000/");

  server.onClientConnect((client) {
    client.close();
    server.close();
  });
  client.onDisconnect(
    (closeCode, closeReason) => print("$closeCode $closeReason"),
  );

  await client.connect();
}
