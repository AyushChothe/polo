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

class LoggerMiddleware implements PoloMiddleware {
  @override
  void clientToServer<T>(String clientId, String event, T data) {
    print("Logger(clientToServer): $clientId:$event:$data");
  }

  @override
  void serverToClient<T>(String clientId, String event, T data) {
    print("Logger(serverToClient): $clientId:$event:$data");
  }

  @override
  void clientConnect(String clientId) {
    print("Logger(clientConnect): $clientId");
  }

  @override
  void clientDisconnect(String clientId) {
    print("Logger(clientDisconnect): $clientId");
  }

  @override
  void clientJoinRoom(String clientId, String room) {
    print("Logger(clientJoinRoom): $clientId:$room");
  }

  @override
  void clientLeaveRoom(String clientId, String room) {
    print("Logger(clientLeaveRoom): $clientId:$room");
  }
}

void main() async {
  // Manager
  // Polo polo = await Polo.createManager(dashboardNamespace: '/dash');
  // PoloServer server = polo.of('/ws');
  PoloServer server = await Polo.createServer();

  // Direct Server
  // PoloServer server = await Polo.createServer(address: "127.0.0.1", port: 3000);

  // Register a Type
  server.registerType<UserType>(
    PoloTypeAdapter<UserType>(
      toMap: (type) => type.toMap(),
      fromMap: (map) => UserType.fromMap(map),
    ),
  );

  // Add Middleware
  server.addMiddleware(LoggerMiddleware());

  server.onClientConnect((client) {
    client.joinRoom('public');
    client.leaveRoom('public');
    client.onEvent<String>(
      'polo:ping',
      (dateTime) => client.send('polo:pong', dateTime),
    );

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

  print("Server Running...");
}
