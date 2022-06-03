import { Polo, PoloClient } from "../polo_client.ts";

// Polo Client
const client: PoloClient = await Polo.connect("ws://127.0.0.1:3000/chat");

client.onConnect(() => {
  console.log("Client Connected to Server");
});

client.onDisconnect(() => {
  console.log("Client Disconnected from Server");
});

client.onEvent("message", (message) => {
  console.log(`${message}`);
});

client.listen();
