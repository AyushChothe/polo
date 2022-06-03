// deno-lint-ignore-file no-explicit-any
import { DataCallback, VoidCallback } from "./types.ts";

class PoloClient {
  private _webSocket: WebSocket;
  private _callbacks: Map<string, DataCallback> = new Map<
    string,
    DataCallback
  >();

  private constructor(webSocket: WebSocket) {
    this._webSocket = webSocket;
  }

  static _(webSocket: WebSocket): PoloClient {
    return new PoloClient(webSocket);
  }

  private _onDisconnectCallback: VoidCallback = () => {};
  private _onConnectCallback: VoidCallback = () => {};

  /// Sets onConnectCallback
  onConnect(callback: VoidCallback): void {
    this._onConnectCallback = callback;
  }

  /// Sets onDisconnectCallback
  onDisconnect(callback: VoidCallback): void {
    this._onDisconnectCallback = callback;
  }

  /// Adds a Callback to an Event
  onEvent(event: string, callback: DataCallback): void {
    this._callbacks.set(event, callback);
  }

  private _emit(event: string, data: any): void {
    if (this._callbacks.get(event)) {
      (this._callbacks.get(event) ?? (() => {}))(data);
    }
  }

  /// Starts listening for messages from `PoloServer`
  listen(): void {
    return this._handleEvents();
  }

  /// Sends message to the Server from Client
  send(event: string, data: any): void {
    this._webSocket.send(JSON.stringify({ event, data }));
  }

  /// Closes the connection to the `PoloServer`
  close(): void {
    return this._webSocket.close();
  }

  private _handleEvents(): void {
    this._onConnectCallback();
    this._webSocket.onclose = (_) => {
      this._onDisconnectCallback();
    };
    try {
      //Listen for Messages from Server
      this._webSocket.onmessage = (message: MessageEvent) => {
        const msg: Map<string, any> = new Map<string, any>(
          Object.entries(JSON.parse(message.data)),
        );
        this._emit(msg.get("event"), msg.get("data"));
      };
    } catch (e) {
      console.log(`Error: ${e}`);
    }
  }
}

export { PoloClient };
