import { PoloClient } from "./polo_client_base.ts";
import { Completer } from "./utils.ts";

class Polo {
  static async connect(url: string): Promise<PoloClient> {
    const ready: Completer<void> = new Completer<void>();

    const client: WebSocket = new WebSocket(url);
    client.onerror = (e) => {
      ready.reject((e as ErrorEvent).error);
    };
    client.onopen = (_) => {
      ready.complete();
    };

    await ready.promise;
    return PoloClient._(client);
  }
}

export { Polo };
