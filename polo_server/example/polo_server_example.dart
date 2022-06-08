import 'package:polo_server/polo_server.dart';

class UserType implements PoloType {
  final String name;
  final int age;

  UserType({required this.name, required this.age});

  factory UserType.fromMap(Map<String, dynamic> map) {
    return UserType(name: map['name'], age: map['age']);
  }

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'age': age};
  }
}

void main() async {
  // Manager
  // Polo polo = await Polo.createManager();
  // PoloServer server = polo.of('/');

  // Direct Server
  PoloServer server = await Polo.createServer(address: "127.0.0.1", port: 3000);

  // Register a Type
  server.registerType<UserType>(
    PoloTypeAdapter<UserType>(
      toMap: (type) => type.toMap(),
      fromMap: (map) => UserType.fromMap(map),
    ),
  );

  server.onClientConnect((client) {
    print("Client(${client.id}) Connected!");

    client.onEvent('dynamic', (dyn) {
      print("Dynamic: $dyn : ${dyn.runtimeType}");
      client.send('dynamic', dyn);
    });

    client.onEvent<String>('message', (message) {
      print("$message : ${message.runtimeType}");
      client.send('message', "Hello from Server");
    });

    client.onEvent<UserType>('userJoined', (user) {
      print("userJoined : ${user.toMap()} : ${user.runtimeType}");
      client.send<UserType>('userJoined', user);
    });
  });

  server.onClientDisconnect((client) {
    print("Client(${client.id}) Disconnected!");
  });

  print("Server Running...");
}
