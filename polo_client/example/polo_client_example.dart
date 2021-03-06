import 'package:polo_client/polo_client.dart';

class UserType implements PoloType {
  final String name;
  final int age;

  UserType({required this.name, required this.age});

  @override
  factory UserType.fromMap(Map<String, dynamic> map) {
    return UserType(name: map['name'], age: map['age']);
  }

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'age': age};
  }
}

void main() async {
  // Polo Client
  PoloClient client = Polo.createClient("ws://127.0.0.1:3000/ws");

  client.registerType(
    PoloTypeAdapter<UserType>(
      toMap: (type) => type.toMap(),
      fromMap: (map) => UserType.fromMap(map),
    ),
  );

  client.onConnect(() {
    print("Client Connected to Server");
    print("${client.protocol}:${client.readyState}");
    // Timer.periodic(Duration(seconds: 1), (timer) {
    //   client.send<String>('polo:ping', DateTime.now().toUtc().toString());
    // });

    client.send('dynamic', "Ayush");
    client.send('dynamic', 1);
    client.send('dynamic', 3.14);
    client.send('dynamic', true);
    client.send('dynamic', [1, 2, 3]);
    client.send('dynamic', null);
    client.send('dynamic', {
      "String": {"dynamic": true}
    });
    client.send<String>('message', "Hello from Client");
    client.send<UserType>('userJoined', UserType(name: "Ayush", age: 22));
  });

  client.onEvent<String>('polo:pong', (dateTime) {
    print(
        "Ping: ${DateTime.now().toUtc().difference(DateTime.parse(dateTime).toUtc()).inMilliseconds} ms");
  });

  client.onEvent('dynamic', (dyn) {
    print("Dynamic: $dyn : ${dyn.runtimeType}");
  });

  client.onEvent<String>('message', (message) {
    print("Message: $message : ${message.runtimeType}");
  });

  client.onEvent<UserType>('userJoined', (user) {
    print("userJoined : ${user.toMap()} : ${user.runtimeType}");
  });

  client.onDisconnect((closeCode, closeReason) {
    print("Client Disconnected from Server($closeCode:$closeReason)");
  });

  client.connect();
}
