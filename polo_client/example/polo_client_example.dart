import 'dart:io';

import 'package:polo_client/polo_client.dart';
import 'package:polo_client/src/polo_type.dart';

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
  stdout.write("Enter Room to join: ");
  // String room = stdin.readLineSync() ?? "root";

  // Polo Client
  PoloClient client = await Polo.connect("ws://127.0.0.1:3000/");

  // PoloClient client =
  //     await Polo.connect("ws://polo-chat-server.herokuapp.com/");

  // Future<void> getInput() async {
  //   stdin.listen((msg) {
  //     client.send('message', String.fromCharCodes(msg).trim());
  //     // client.send('messageToRoom',
  //     //     {"room": room, "message": String.fromCharCodes(msg).trim()});
  //   });
  // }

  client.onConnect(() {
    print("Client Connected to Server");
    client.send('dynamic', "Ayush");
    client.send('dynamic', 1);
    client.send('dynamic', 3.14);
    client.send('dynamic', true);
    client.send('dynamic', [1, 2, 3]);
    client.send('dynamic', {
      "String": {"dynamic": true}
    });
    client.send<String>('message', "Hello from Client");
    client.send<UserType>('userJoined', UserType(name: "Ayush", age: 22));
  });

  client.onDisconnect(() {
    print("Client Disconnected from Server");
  });

  client.onEvent('dynamic', (dyn) {
    stdout.writeln("Dynamic: $dyn : ${dyn.runtimeType}");
  });

  client.onEvent<String>('message', (message) {
    stdout.writeln("Message: $message : ${message.runtimeType}");
  });

  client.onEvent<UserType>('userJoined', (user) {
    stdout.writeln("userJoined : ${user.toMap()} : ${user.runtimeType}");
  }, converter: UserType());

  client.listen();
  // getInput();
}
