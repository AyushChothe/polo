# Polo: WebSocket Library

[![](https://img.shields.io/badge/Dart-%E2%9D%A4-blue)](https://dart.dev/)

### A WebSocket Library written in Pure Dart. Easy API for writing WebSocket based Apps or Games. Also Support for Flutter and Web.

## ✨ Features

- **Multi-Platform**
  - ` Android`, `IOS`, `Windows`, `Linux`, `macOS`, `Web`
- **Easy to Use API**

## Getting Started

### **Baic Chat App**

- Server Code

```dart
// Polo Server
  PoloServer server = await Polo.createServer();

  server.onClientConnect((client) {
    print("Client(${client.id}) Connected!");

    client.onEvent('message',
        (message) => server.broadcastFrom(client.id, 'message', message));
  });

  server.onClientDisconnect((client) {
    print("Client(${client.id}) Disconnected!");
  });
```

- Client Code

```dart
  // Polo Client
  PoloClient client = await Polo.connect("ws://127.0.0.1:3000/");

  // PoloWecClient (if using from Flutter Web or Dart Web (webdev))
  PoloWebClient client = await PoloWeb.connect("ws://127.0.0.1:3000/");

  client.onConnect(() {
    print("Client Connected to Server");
  });

  client.onDisconnect(() {
    print("Client Disconnected from Server");
  });

  client.onEvent('message', (message) {
    print("$message");
  });

  client.listen();
```

## 💪 Contributions

- [Ayush Chothe](https://sh0rt.now.sh/ASH)
