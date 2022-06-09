import { Polo, PoloClient } from "../polo_client.ts";

interface UserType {
  name: string;
  age: number;
}

// Polo Client
const client: PoloClient = await Polo.connect(
  "ws://127.0.0.1:3000/",
);

client.onConnect(() => {
  console.log("Client Connected to Server");

  setInterval(() => {
    client.send<string>("polo:ping", new Date().toISOString());
  }, 1000);

  client.send("dynamic", "Ayush");
  client.send("dynamic", 1);
  client.send("dynamic", 3.14);
  client.send("dynamic", true);
  client.send("dynamic", [1, 2, 3]);
  client.send("dynamic", null);
  client.send("dynamic", {
    "String": { "dynamic": true },
  });
  client.send<string>("message", "Hello from Client");
  client.send<UserType>("userJoined", <UserType> { name: "Ayush", age: 22 });
});

client.onEvent<string>("polo:pong", (dateTime) => {
  console.log(
    `Ping: ${((new Date().getTime()) - (new Date(dateTime).getTime()))} ms`,
  );
});

client.onEvent("dynamic", (dyn) => {
  console.log(`Dynamic: ${dyn} : ${typeof dyn}`);
});

client.onEvent<string>("message", (message) => {
  console.log(`Message: ${message} : ${typeof message}`);
});

client.onEvent<UserType>("userJoined", (user) => {
  console.log(`userJoined : ${JSON.stringify(user)} : ${typeof user}`);
});

client.onDisconnect(() => {
  console.log("Client Disconnected from Server");
});

client.listen();
