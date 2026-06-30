"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RaceMatch = void 0;
const colyseus_1 = require("colyseus");
class RaceMatch extends colyseus_1.Room {
    constructor() {
        super(...arguments);
        this.players = {};
        this.placements = [];
        this.maxClients = 4;
        this.availableRaceStarts = [1, 2, 3, 4];
        this.id_list = [];
        this.seed = 0;
    }
    onCreate(options) {
        try {
            this.maxClients = options;
            this.onMessage("submit_turtle", (client, turtle_build) => {
                this.players[client.sessionId].build = turtle_build;
                this.players[client.sessionId].ready = true;
                var counter = 0;
                for (const id of Object.keys(this.players)) {
                    if (this.players[id].ready == true) {
                        counter += 1;
                    }
                }
                if (counter == 4) {
                    console.log("wooo");
                    this.broadcast("send_turtles", this.players);
                    const startTime = Date.now() + 3000;
                    this.broadcast("race_start", { startTime: startTime });
                    //this.startRace();
                }
            });
            this.onMessage("Unready", (client) => {
                this.players[client.sessionId].ready = false;
            });
            this.onMessage("enter_shop", (client, message) => {
                console.log(this.id_list);
                this.broadcast("id_list", this.id_list);
                this.seed = Math.floor(Math.random() * 1000000);
                console.log("New seed:", this.seed);
                this.broadcast("seed", this.seed);
            });
        }
        catch (e) {
            console.log("ROOM FAILED TO CREATE in Race Match:", e);
        }
    }
    onJoin(client) {
        try {
            console.log(client.sessionId + " is in the race!");
            var race_slot = Number(this.availableRaceStarts.shift());
            this.players[client.sessionId] = {
                build: {
                    leftArm: null,
                    rightArm: null,
                    head: null,
                    shell: null,
                    legs: null
                },
                slot: race_slot,
                finished: false,
                placement: null,
                ready: false
            };
            this.id_list.push(client.sessionId);
        }
        catch (e) {
            console.log("ROOM FAILED TO CREATE in Join Race Match:", e);
        }
    }
    onLeave(client) {
        console.log(client.sessionId, "left race");
        if (this.players[client.sessionId]) {
            this.availableRaceStarts.push(this.players[client.sessionId].slot);
        }
        delete this.players[client.sessionId];
    }
}
exports.RaceMatch = RaceMatch;
//# sourceMappingURL=RaceMatch.js.map