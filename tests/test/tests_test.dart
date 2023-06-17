@Timeout(Duration(seconds: 60))
import 'package:polo_client/polo_client.dart' as pc;
import 'package:polo_server/polo_server.dart' as ps;
import 'package:test/test.dart';

void main() {
  group("Connection Test", (() {
    test("createServer", () async {
      ps.PoloServer server =
          await ps.Polo.createServer(address: "127.0.0.1", port: 3000);
      pc.PoloClient client = pc.Polo.createClient("ws://127.0.0.1:3000/");

      server.onClientConnect = ((client) {
        client.close();
        server.close();
      });

      await client.connect();
    });

    test("createManager", () async {
      ps.Polo manager =
          await ps.Polo.createManager(address: "127.0.0.1", port: 3000);
      ps.PoloServer server = manager.of('/');
      pc.PoloClient client = pc.Polo.createClient("ws://127.0.0.1:3000/");

      server.onClientConnect = ((client) {
        client.close();
        server.close();
      });

      await client.connect();
    });
  }));

  group("Message Test", (() {
    test("String", () async {
      String send = "Hello Polo";
      String recv = "";

      ps.PoloServer server =
          await ps.Polo.createServer(address: "127.0.0.1", port: 3001);
      pc.PoloClient client = pc.Polo.createClient("ws://127.0.0.1:3001/");

      server.onClientConnect = ((client) {
        client.send<String>("string", send);
        server.close();
      });

      client.onEvent<String>("string", (data) {
        recv = data;
        client.close();
      });

      await client.connect();
      expect(recv, equals(send));
    });
    test("int", () async {
      int send = 10;
      int recv = 0;

      ps.PoloServer server =
          await ps.Polo.createServer(address: "127.0.0.1", port: 3001);
      pc.PoloClient client = pc.Polo.createClient("ws://127.0.0.1:3001/");

      server.onClientConnect = ((client) {
        client.send<int>("int", send);
        server.close();
      });

      client.onEvent<int>("int", (data) {
        recv = data;
        client.close();
      });

      await client.connect();
      expect(recv, equals(send));
    });
    test("double", () async {
      double send = 3.14;
      double recv = 0.0;

      ps.PoloServer server =
          await ps.Polo.createServer(address: "127.0.0.1", port: 3001);
      pc.PoloClient client = pc.Polo.createClient("ws://127.0.0.1:3001/");

      server.onClientConnect = ((client) {
        client.send<double>("double", send);
        server.close();
      });

      client.onEvent<double>("double", (data) {
        recv = data;
        client.close();
      });

      await client.connect();
      expect(recv, equals(send));
    });
    test("bool", () async {
      bool send = true;
      bool recv = false;

      ps.PoloServer server =
          await ps.Polo.createServer(address: "127.0.0.1", port: 3001);
      pc.PoloClient client = pc.Polo.createClient("ws://127.0.0.1:3001/");

      server.onClientConnect = ((client) {
        client.send<bool>("bool", send);
        server.close();
      });

      client.onEvent<bool>("bool", (data) {
        recv = data;
        client.close();
      });

      await client.connect();
      expect(recv, equals(send));
    });
    test("List", () async {
      List<String> send = ["Ayush", "Mahesh", "Chothe"];
      List<String> recv = [];

      ps.PoloServer server =
          await ps.Polo.createServer(address: "127.0.0.1", port: 3001);
      pc.PoloClient client = pc.Polo.createClient("ws://127.0.0.1:3001/");

      server.onClientConnect = ((client) {
        client.send<List<String>>("List", send);
        server.close();
      });

      client.onEvent<List<dynamic>>("List", (data) {
        recv = data.cast();
        client.close();
      });

      await client.connect();
      // expect(recv, equals(send));
    });
  }));
}
