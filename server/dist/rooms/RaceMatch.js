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
        this.perm_name_list = [];
        this.id_name_list = [];
        this.name_list = [];
        this.seed = 0;
    }
    onCreate(options) {
        try {
            console.log("multiplayer");
            this.maxClients = options[0];
            this.name_list = options[1];
            this.perm_name_list = options[1].slice();
            this.onMessage("submit_turtle", (client, turtle_build) => {
                this.players[client.sessionId].build.items = turtle_build["items"];
                this.players[client.sessionId].build.base_stats = turtle_build["base_stats"];
                this.players[client.sessionId].build.econ = turtle_build["econ"];
                console.log(this.players[client.sessionId].name + " " + turtle_build);
                this.players[client.sessionId].name = turtle_build["name"];
                this.players[client.sessionId].build.name = turtle_build["name"];
                this.players[client.sessionId].ready = true;
                var counter = 0;
                for (const id of Object.keys(this.players)) {
                    if (this.players[id].ready == true) {
                        counter += 1;
                    }
                }
                if (counter == 4) {
                    console.log("wooo");
                    for (const id of Object.keys(this.players)) {
                        this.id_name_list.push([id, this.players[id].name]);
                    }
                    this.broadcast("id_with_name", this.id_name_list);
                    this.broadcast("send_turtles", this.players);
                    const startTime = Date.now() + 3000;
                    this.broadcast("race_start", { startTime: startTime });
                }
            });
            this.onMessage("Unready", (client) => {
                this.players[client.sessionId].ready = false;
            });
            this.onMessage("keepingServerUp", (client, message) => {
                void 0;
            });
            this.onMessage("enter_shop", (client, message) => {
                console.log(this.perm_name_list);
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
            var race_slot = Number(this.availableRaceStarts.shift());
            var name_remaining = String(this.name_list.shift());
            console.log(name_remaining);
            this.players[client.sessionId] = {
                build: {
                    items: {
                        leftArm: null,
                        rightArm: null,
                        head: null,
                        shell: null,
                        legs: null
                    },
                    base_stats: {
                        acceleration: 5.0,
                        resilience: 0.1,
                        max_speed: 300.0,
                        fire_rate: 1.0,
                        projectile_speed: 1.0,
                        luck: 1.0
                    },
                    econ: {
                        gold: 10
                    },
                    name: "error"
                },
                slot: race_slot,
                finished: false,
                placement: null,
                ready: false,
                name: name_remaining
            };
            //client.sessionId = this.players[client.sessionId].name
            console.log(this.players[client.sessionId].name + " is in the race!");
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
            this.name_list.push(this.players[client.sessionId].name);
        }
        delete this.players[client.sessionId];
    }
}
exports.RaceMatch = RaceMatch;
//# sourceMappingURL=RaceMatch.js.map