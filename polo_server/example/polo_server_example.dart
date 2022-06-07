import 'package:polo_server/polo_server.dart';
import 'package:polo_server/src/polo_type.dart';

class UserType implements PoloType {
  String? name;
  int? age;

  UserType({this.name, this.age});

  @override
  UserType fromMap(Map<String, dynamic> map) {
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
  // PoloServer server = polo.of('/chat');

  // Direct Server
  PoloServer server = await Polo.createServer();

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

    client.onEvent<UserType>(
      'userJoined',
      (user) {
        print("userJoined : ${user.toMap()} : ${user.runtimeType}");
        client.send<UserType>('userJoined', user);
      },
      converter: UserType(),
    );

    // client.onEvent<String>('message',
    //     (message) => server.broadcastFrom(client, 'message', message));

    // client.onEvent(
    //     'messageToRoom',
    //     (payload) => server.broadcastToRoom(
    //         client, payload['room'], 'message', payload['message']));

    // client.onEvent('joinRoom', (room) {
    //   client.joinRoom(room);
    // });

    // client.onEvent('leaveRoom', (room) {
    //   client.leaveRoom(room);
    // });
  });

  server.onClientDisconnect((client) {
    print("Client(${client.id}) Disconnected!");
  });

  print("Server Running...");
}
