# Polo: WebSocket Library

### A WebSocket Library written in Pure Dart. Easy API for writing WebSocket based Apps or Games, also Support for Flutter and Web.

## 📦 Packages

| Name           | Link                                                                                                                                          | Language / Runtime |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------ |
| polo_server    | [![pub package](https://img.shields.io/pub/v/polo_server.svg?label=polo_server&color=blue)](https://pub.dartlang.org/packages/polo_server)    | Dart               |
| polo_client    | [![pub package](https://img.shields.io/pub/v/polo_client.svg?label=polo_client&color=blue)](https://pub.dartlang.org/packages/polo_client)    | Dart               |
| polo_client_ts | [![pub package](https://img.shields.io/pub/v/polo_client.svg?label=polo_client_ts&color=blue)](https://pub.dartlang.org/packages/polo_client) | Deno (TypeScript)  |

## ✨ Features

- **Multi-Platform**
  - `Android`, `IOS`, `Windows`, `Linux`, `macOS`, `Web`.
- **Typed Events**
  - Refer `PoloType` and `PoloTypeAdapter`.
- **Library Officially Available in Multiple Programming Languages**
  - `Dart`, `TypeScript`.
- **Easy to Use API**

## 📖 Getting Started

### **Basic Chat App**

- Server Code (Dart)

```dart
  // Polo Server
  PoloServer server = await Polo.createServer();

  server.onClientConnect((client) {
    print("Client(${client.id}) Connected!");

    client.onEvent<String>('message',
        (message) => server.broadcastFrom<String>(client, 'message', message));
  });

  server.onClientDisconnect((client) {
    print("Client(${client.id}) Disconnected!");
  });
```

- Client Code (Dart)

```dart
  // Polo Client
  PoloClient client = await Polo.connect("ws://127.0.0.1:3000/");

  client.onConnect(() {
    print("Client Connected to Server");
  });

  client.onDisconnect(() {
    print("Client Disconnected from Server");
  });

  client.onEvent<String>('message', (message) {
    print("$message");
  });

  client.listen();
```

- Client Code (TypeScript)

```ts
// Polo Client
const client: PoloClient = await Polo.connect("ws://127.0.0.1:3000/");

client.onConnect(() => {
  console.log("Client Connected to Server");
});

client.onDisconnect(() => {
  console.log("Client Disconnected from Server");
});

client.onEvent<string>("message", (message) => {
  console.log(`${message}`);
});

client.listen();
```

## 💪 Contributions

- [Ayush Chothe](https://sh0rt.now.sh/ASH)
