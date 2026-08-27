"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.BotLobby = void 0;
const colyseus_1 = require("colyseus");
const colyseus_2 = require("colyseus");
class BotLobby extends colyseus_1.Room {
    constructor() {
        super(...arguments);
        this.maxClients = 4;
        this.availableRaceStarts = [1, 2, 3, 4];
        this.seed = 0;
        this.players = {};
        this.name_list = [];
    }
    onCreate() {
        try {
            console.log("RaceLobby created");
            this.onMessage("ready", (client) => {
                this.players[client.sessionId].ready = true;
                console.log(client.sessionId, " is ready!");
                var slot = Number(this.availableRaceStarts.shift());
                this.players["CPU1"] = {
                    ready: true,
                    race_order: slot,
                    name: "CPU1"
                };
                slot = Number(this.availableRaceStarts.shift());
                this.players["CPU2"] = {
                    ready: true,
                    race_order: slot,
                    name: "CPU2"
                };
                slot = Number(this.availableRaceStarts.shift());
                this.players["CPU3"] = {
                    ready: true,
                    race_order: slot,
                    name: "CPU3"
                };
                this.sendLobbyUpdate();
                this.checkStart();
            });
        }
        catch (e) {
            console.log("ROOM FAILED TO CREATE in Race Lobby:", e);
        }
    }
    onJoin(client, options) {
        console.log(options.player_name, "joined race");
        if (this.availableRaceStarts.length == 0) {
            client.leave();
            return;
        }
        for (const player in this.players) {
            if (this.players[player].name == options.player_name)
                options.player_name = client.sessionId;
        }
        ;
        var slot = Number(this.availableRaceStarts.shift());
        //client.sessionId = options.player_name
        this.players[client.sessionId] = {
            ready: false,
            race_order: slot,
            name: options.player_name
        };
        client.send("session_id", client.sessionId);
        this.name_list.push(this.players[client.sessionId].name);
        this.sendLobbyUpdate();
    }
    onLeave(client) {
        console.log(client.sessionId, "left race");
        if (this.players[client.sessionId]) {
            this.availableRaceStarts.push(this.players[client.sessionId].race_order);
        }
        ;
        var index = this.name_list.indexOf(this.players[client.sessionId].name);
        if (index !== -1) {
            this.name_list.splice(index, 1);
        }
        ;
        delete this.players[client.sessionId];
        this.sendLobbyUpdate();
    }
    checkStart() {
        const allReady = Object.keys(this.players).length === this.maxClients &&
            Object.values(this.players).every(p => p.ready);
        if (!allReady)
            return;
        this.startRace();
    }
    sendLobbyUpdate() {
        const lobby = [];
        for (const id in this.players) {
            lobby.push({ ready: this.players[id].ready, slot: this.players[id].race_order, name: this.players[id].name });
        }
        this.broadcast("lobby_update", lobby);
    }
    startRace() {
        return __awaiter(this, void 0, void 0, function* () {
            var room_location;
            room_location = "raceMatchLocal";
            const raceRoom = yield colyseus_2.matchMaker.createRoom(room_location, [this.maxClients, this.name_list]);
            console.log(this.players);
            console.log(this.name_list);
            this.broadcast("load_race", { roomId: raceRoom.roomId });
            this.seed = Math.floor(Math.random() * 1000000);
            console.log("Starting race with seed:", this.seed);
            this.broadcast("seed", this.seed);
        });
    }
}
exports.BotLobby = BotLobby;
//# sourceMappingURL=BotLobby.js.map