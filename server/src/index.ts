import http from "http";
import express from "express";
import { Server, LobbyRoom } from "colyseus";
import { WebSocketTransport } from "@colyseus/ws-transport";
import { RaceLobby } from "./rooms/RaceLobby.js"
import { RaceMatch } from "./rooms/RaceMatch.js"
import { RaceMatchLocal } from "./rooms/RaceMatchLocal.js"

const port = Number(process.env.PORT) || 2567;
const app = express();
const server = http.createServer(app);
const gameServer = new Server({
    transport: new WebSocketTransport({
        server: server
    }),
    presence: undefined,
    driver: undefined
});

console.log("REGISTERING ROOM");
gameServer.define("lobby", LobbyRoom);
gameServer.define("raceLobby", RaceLobby).enableRealtimeListing();
gameServer.define("raceMatch", RaceMatch);
gameServer.define("raceMatchLocal", RaceMatchLocal);

gameServer.listen(port);

console.log(`Server running on ws://localhost:${port}`);

gameServer.onShutdown(() => {
  console.log("SERVER SHUTDOWN");
});