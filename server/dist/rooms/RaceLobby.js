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
exports.RaceLobby = void 0;
const colyseus_1 = require("colyseus");
class RaceLobby extends colyseus_1.Room {
    constructor() {
        super(...arguments);
        this.maxClients = 1000;
        this.MATCH_SIZE = 4;
        this.queue = [];
        this.players = {};
        this.bosses = ["Rabbit"];
        this.matchmaking = false;
    }
    onCreate(options) {
        console.log("Matchmaking queue created ", this.roomId);
    }
    onJoin(client, options) {
        console.log("JOIN: ", client.sessionId, " Room: ", this.roomId);
        let playerName = String(options.player_name || "Player");
        if (Object.values(this.players).some(p => p.name === playerName)) {
            playerName += `_${client.sessionId.slice(0, 4)}`;
        }
        this.players[client.sessionId] = {
            ready: false,
            race_order: 0,
            name: playerName
        };
        this.queue.push(client.sessionId);
        client.send("session_id", client.sessionId);
        client.send("queue_status", { searching: true });
        console.log(`${playerName} joined queue ${this.roomId}. Queue size: ${this.queue.length}`);
        void this.checkStart();
    }
    onLeave(client, code) {
        console.log("LEAVE:", client.sessionId, "Room:", this.roomId, "Code:", code);
        this.queue = this.queue.filter(id => id !== client.sessionId);
        console.log("Queue size after leave:", this.queue.length);
        const index = this.queue.indexOf(client.sessionId);
        if (index !== -1) {
            this.queue.splice(index, 1);
            console.log(`${client.sessionId} left the queue.`);
        }
        delete this.players[client.sessionId];
    }
    checkStart() {
        return __awaiter(this, void 0, void 0, function* () {
            if (this.matchmaking)
                return;
            this.matchmaking = true;
            try {
                while (this.queue.length >= this.MATCH_SIZE) {
                    const sessionIds = this.queue.splice(0, this.MATCH_SIZE);
                    const group = sessionIds
                        .map(id => ({ id, player: this.players[id] }))
                        .filter(entry => entry.player);
                    if (group.length !== this.MATCH_SIZE) {
                        for (const entry of group.reverse()) {
                            if (this.clients.some(c => c.sessionId === entry.id)) {
                                this.queue.unshift(entry.id);
                            }
                        }
                        continue;
                    }
                    const nameList = group.map(entry => entry.player.name);
                    const seed = Math.floor(Math.random() * 1000000);
                    const boss = this.bosses[Math.floor(Math.random() * this.bosses.length)];
                    try {
                        const raceRoom = yield colyseus_1.matchMaker.createRoom("raceMatch", {
                            maxClients: this.MATCH_SIZE,
                            nameList,
                            end_boss: boss,
                            seed
                        });
                        // Recheck connections after the asynchronous room creation.
                        const connectedGroup = group.filter(entry => this.clients.some(c => c.sessionId === entry.id) &&
                            this.players[entry.id] !== undefined);
                        if (connectedGroup.length !== this.MATCH_SIZE) {
                            console.log("Match cancelled: a player disconnected during creation.");
                            // Restore connected players to the front of the queue.
                            for (const entry of connectedGroup.reverse()) {
                                this.queue.unshift(entry.id);
                            }
                            // Players who disconnected are already removed by onLeave().
                            // Retry if enough players remain queued.
                            continue;
                        }
                        // All four players are still connected; assign the match.
                        for (let i = 0; i < group.length; i++) {
                            const entry = group[i];
                            const client = this.clients.find(c => c.sessionId === entry.id);
                            if (!client)
                                continue;
                            entry.player.race_order = i + 1;
                            delete this.players[entry.id];
                            client.send("load_race", { roomId: raceRoom.roomId });
                            client.send("seed", seed);
                            client.send("queue_status", { searching: false });
                        }
                        console.log("Match created:", raceRoom.roomId);
                        console.log("Players:", nameList);
                        console.log("Seed:", seed);
                    }
                    catch (error) {
                        console.error("Failed to create race match:", error);
                        for (const entry of group.reverse()) {
                            if (this.clients.some(c => c.sessionId === entry.id)) {
                                this.players[entry.id] = entry.player;
                                this.queue.unshift(entry.id);
                            }
                        }
                        break;
                    }
                }
            }
            finally {
                this.matchmaking = false;
            }
            if (this.queue.length >= this.MATCH_SIZE) {
                void this.checkStart();
            }
        });
    }
}
exports.RaceLobby = RaceLobby;
//# sourceMappingURL=RaceLobby.js.map