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
exports.RaceMatchLocal = void 0;
const colyseus_1 = require("colyseus");
const botBuilds_js_1 = require("../bots/botBuilds.js");
const botBuilds_js_2 = require("../bots/botBuilds.js");
const builds = new botBuilds_js_1.botBuilds();
class RaceMatchLocal extends colyseus_1.Room {
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
        this.round = 0;
        this.availableBots = [...botBuilds_js_2.bot_list];
        this.cpu1 = "";
        this.cpu2 = "";
        this.cpu3 = "";
    }
    onCreate(options) {
        try {
            this.initialized = new Promise((resolve) => {
                this.initialize = resolve;
            });
            console.log("setting up bots");
            this.maxClients = options[0];
            this.name_list = options[1];
            this.perm_name_list = options[1].slice();
            console.log("bot set up finished");
            this.initialize();
            this.onMessage("submit_turtle", (client, turtle_build) => {
                this.players[client.sessionId].build.items = turtle_build["items"];
                this.players[client.sessionId].build.base_stats = turtle_build["base_stats"];
                this.players[client.sessionId].build.econ = turtle_build["econ"];
                this.round += 1;
                if (this.round > 3) {
                    this.round = 3;
                }
                ;
                console.log(this.players[client.sessionId].name + " " + turtle_build);
                this.players[client.sessionId].ready = true;
                this.players["CPU1"].build.items = builds.turtles[this.round][this.cpu1]["items"];
                this.players["CPU1"].build.base_stats = builds.turtles[this.round][this.cpu1]["base_stats"];
                this.players["CPU1"].build.econ = builds.turtles[this.round][this.cpu1]["econ"];
                this.players["CPU1"].ready = true;
                this.players["CPU2"].build.items = builds.turtles[this.round][this.cpu2]["items"];
                this.players["CPU2"].build.base_stats = builds.turtles[this.round][this.cpu2]["base_stats"];
                this.players["CPU2"].build.econ = builds.turtles[this.round][this.cpu2]["econ"];
                this.players["CPU2"].ready = true;
                this.players["CPU3"].build.items = builds.turtles[this.round][this.cpu3]["items"];
                this.players["CPU3"].build.base_stats = builds.turtles[this.round][this.cpu3]["base_stats"];
                this.players["CPU3"].build.econ = builds.turtles[this.round][this.cpu3]["econ"];
                this.players["CPU3"].ready = true;
                this.raceStart(client);
            });
            this.onMessage("Unready", (client) => {
                this.players[client.sessionId].ready = false;
            });
            this.onMessage("keepingServerUp", (client, message) => {
                void 0;
            });
        }
        catch (e) {
            console.log("ROOM FAILED TO CREATE in Race Match:", e);
        }
    }
    onJoin(client) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.initialized;
            try {
                //var race_slot = Number(this.availableRaceStarts.shift());
                var name_remaining = String(this.perm_name_list.shift());
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
                        }
                    },
                    slot: 1,
                    finished: false,
                    placement: null,
                    ready: false,
                    name: name_remaining
                };
                //client.sessionId = this.players[client.sessionId].name
                console.log(this.players[client.sessionId].name + " is in the race!");
                this.players["CPU1"] = {
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
                        }
                    },
                    slot: 2,
                    finished: false,
                    placement: null,
                    ready: true,
                    name: "CPU1"
                };
                this.players["CPU2"] = {
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
                        }
                    },
                    slot: 3,
                    finished: false,
                    placement: null,
                    ready: true,
                    name: "CPU2"
                };
                this.players["CPU3"] = {
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
                        }
                    },
                    slot: 4,
                    finished: false,
                    placement: null,
                    ready: true,
                    name: "CPU3"
                };
                this.cpu1 = this.availableBots[Math.floor(Math.random() * this.availableBots.length)];
                this.availableBots.splice(this.availableBots.indexOf(this.cpu1), 1);
                this.cpu2 = this.availableBots[Math.floor(Math.random() * this.availableBots.length)];
                this.availableBots.splice(this.availableBots.indexOf(this.cpu2), 1);
                this.cpu3 = this.availableBots[Math.floor(Math.random() * this.availableBots.length)];
                this.id_list.push(client.sessionId);
                this.id_list.push("CPU1");
                this.id_list.push("CPU2");
                this.id_list.push("CPU3");
                console.log("computers here ", this.id_list);
                this.broadcast("id_list", this.id_list);
            }
            catch (e) {
                console.log("ROOM FAILED TO CREATE in Join Race Match:", e);
            }
        });
    }
    onLeave(client) {
        console.log(client.sessionId, "left race");
        this.availableRaceStarts.push(this.players[client.sessionId].slot);
        this.name_list.push(this.players[client.sessionId].name);
        const index = this.id_list.indexOf(client.session_id.name);
        if (index != -1) {
            this.id_list.splice(index, 1);
        }
        ;
        delete this.players[client.sessionId];
        this.maxClients -= 1;
        console.log(" new clients and players ", [this.maxClients, this.players]);
        this.raceStart(client);
    }
    raceStart(client) {
        var counter = 0;
        for (const id of Object.keys(this.players)) {
            if (this.players[id].ready == true) {
                counter += 1;
            }
        }
        if (counter >= this.maxClients) {
            console.log("wooo");
            for (const id of Object.keys(this.players)) {
                this.id_name_list.push([id, this.players[id].name]);
            }
            this.seed = Math.floor(Math.random() * 1000000);
            this.broadcast("seed", this.seed);
            this.broadcast("id_list", this.id_list);
            this.broadcast("id_with_name", this.id_name_list);
            this.broadcast("send_turtles", this.players);
            const startTime = Date.now() + 3000;
            this.broadcast("race_start", { startTime: startTime });
        }
    }
}
exports.RaceMatchLocal = RaceMatchLocal;
//# sourceMappingURL=RaceMatchLocal.js.map