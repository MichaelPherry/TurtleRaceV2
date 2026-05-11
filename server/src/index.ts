import http from "http";
import express from "express";
import { Server } from "colyseus";
import { WebSocketTransport } from "@colyseus/ws-transport";
import { MatchmakingRoom } from "./rooms/MatchmakingRoom.js";

const port = 2567;
const app = express();
const server = http.createServer(app);
const gameServer = new Server({
    transport: new WebSocketTransport({
        server: server
    })
});

console.log("REGISTERING ROOM");
gameServer.define("matchmaking", MatchmakingRoom);
console.log("AAAAAAA");
gameServer.listen(port);

console.log(`Server running on ws://localhost:${port}`);

gameServer.onShutdown(() => {
  console.log("SERVER SHUTDOWN");
});