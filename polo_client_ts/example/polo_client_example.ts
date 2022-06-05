import { Polo, PoloClient } from "../polo_client.ts";

// Polo Client
const client: PoloClient = await Polo.connect(
  "ws://polo-chat-server.herokuapp.com/",
);

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
client.send("message", "Hello");
