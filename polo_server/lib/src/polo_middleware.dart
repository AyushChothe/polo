abstract class PoloMiddleware {
  void clientConnect(String clientId) {
    throw UnimplementedError();
  }

  void clientDisconnect(String clientId) {
    throw UnimplementedError();
  }

  void clientJoinRoom(String clientId, String room) {
    throw UnimplementedError();
  }

  void clientLeaveRoom(String clientId, String room) {
    throw UnimplementedError();
  }

  void serverToClient<T>(String clientId, String event, T data) {
    throw UnimplementedError();
  }

  void clientToServer<T>(String clientId, String event, T data) {
    throw UnimplementedError();
  }
}

void mwCC(List<PoloMiddleware> middlewares, String clientId) {
  for (final mw in middlewares) {
    mw.clientConnect(clientId);
  }
}

void mwCD(List<PoloMiddleware> middlewares, String clientId, int? closeCode,
    String? closeReason,) {
  for (final mw in middlewares) {
    mw.clientDisconnect(clientId);
  }
}

void mwJR(List<PoloMiddleware> middlewares, String clientId, String room) {
  for (final mw in middlewares) {
    mw.clientJoinRoom(clientId, room);
  }
}

void mwLR(List<PoloMiddleware> middlewares, String clientId, String room) {
  for (final mw in middlewares) {
    mw.clientLeaveRoom(clientId, room);
  }
}

void mwSTC<T>(
    List<PoloMiddleware> middlewares, String clientId, String event, T data,) {
  for (final mw in middlewares) {
    mw.serverToClient<T>(clientId, event, data);
  }
}

void mwCTS<T>(
    List<PoloMiddleware> middlewares, String clientId, String event, T data,) {
  for (final mw in middlewares) {
    mw.clientToServer<T>(clientId, event, data);
  }
}
