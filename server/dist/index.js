"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const http_1 = __importDefault(require("http"));
const express_1 = __importDefault(require("express"));
const colyseus_1 = require("colyseus");
const ws_transport_1 = require("@colyseus/ws-transport");
const RaceLobby_js_1 = require("./rooms/RaceLobby.js");
const RaceMatch_js_1 = require("./rooms/RaceMatch.js");
const port = Number(process.env.PORT) || 2567;
const app = (0, express_1.default)();
const server = http_1.default.createServer(app);
const gameServer = new colyseus_1.Server({
    transport: new ws_transport_1.WebSocketTransport({
        server: server
    })
});
console.log("REGISTERING ROOM");
gameServer.define("raceLobby", RaceLobby_js_1.RaceLobby);
gameServer.define("raceMatch", RaceMatch_js_1.RaceMatch);
console.log("AAAAAAA");
gameServer.listen(port);
console.log(`Server running on ws://localhost:${port}`);
gameServer.onShutdown(() => {
    console.log("SERVER SHUTDOWN");
});
//# sourceMappingURL=index.js.map