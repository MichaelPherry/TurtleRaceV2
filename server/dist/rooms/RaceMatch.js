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
exports.RaceMatch = void 0;
const colyseus_1 = require("colyseus");
const botBuilds_js_1 = require("../bots/botBuilds.js");
const bosses = new botBuilds_js_1.bossBuilds();
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
        this.seeds_boss = "";
        this.wins = new Map();
        this.raceResults = new Map();
        this.lastResults = [];
        this.bossRequests = new Set();
        this.bossRaceActive = false;
        this.bossRaceActiveCounter = 0;
        this.bossQueue = [];
    }
    onCreate(options) {
        try {
            this.initialized = new Promise((resolve) => {
                this.initialize = resolve;
            });
            console.log("RACE MATCH OPTIONS:", options);
            this.maxClients = options.maxClients;
            this.name_list = options.nameList.slice();
            this.perm_name_list = options.nameList.slice();
            this.seeds_boss = options.end_boss;
            console.log("set up finished");
            console.log("NAME LIST ", this.name_list);
            this.initialize();
            this.onMessage("submit_turtle", (client, turtle_build) => {
                this.players[client.sessionId].build.items = turtle_build["items"];
                this.players[client.sessionId].build.base_stats = turtle_build["base_stats"];
                this.players[client.sessionId].build.econ = turtle_build["econ"];
                console.log(this.players[client.sessionId].name + " " + turtle_build);
                this.players[client.sessionId].name = turtle_build["name"];
                this.players[client.sessionId].build.name = turtle_build["name"];
                this.players[client.sessionId].ready = true;
                this.raceStart(client);
            });
            this.onMessage("Unready", (client) => {
                this.players[client.sessionId].ready = false;
            });
            this.onMessage("raceResults", (client, message) => {
                this.raceResults.set(client.sessionId, message);
                console.log("Race results are ", this.raceResults);
                if (this.raceResults.size == this.maxClients) {
                    var results = this.standardizeResults();
                    let num_to_word = "fourth";
                    for (var placement of Object.keys(results)) {
                        if (Number(placement) == 1) {
                            num_to_word = "first";
                        }
                        ;
                        if (Number(placement) == 2) {
                            num_to_word = "second";
                        }
                        ;
                        if (Number(placement) == 3) {
                            num_to_word = "third";
                        }
                        ;
                        if (Number(placement) == 4) {
                            num_to_word = "fourth";
                        }
                        ;
                        var racer = message[placement][0];
                        console.log("message: ", message);
                        console.log("placement:", placement);
                        console.log("racer:", racer);
                        console.log("players:", this.players);
                        console.log("players:", this.players[racer].build.results);
                        this.players[racer].build.results[num_to_word] += 1;
                    }
                    ;
                }
                ;
            });
            this.onMessage("request_boss_race", (client, message) => {
                const player = this.players[client.sessionId];
                if (this.bossRequests.has(client.sessionId))
                    return;
                this.bossRequests.add(client.sessionId);
                this.updateBossQueue();
                //this.broadcast("race_start", {startTime: startTime});
            });
            this.onMessage("boss_not_active", (client, message) => {
                this.bossRaceActiveCounter += 1;
                if (this.bossRaceActiveCounter >= this.maxClients) {
                    this.bossRaceActive = false;
                }
                ;
            });
            this.onMessage("start_race_after_boss", (client, message) => {
                this.players[client.sessionId].ready = true;
                this.bossRaceActive = false;
                this.raceStart(client);
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
                console.log("NAME LIST WHEN JOINING:", this.name_list);
                var race_slot = Number(this.availableRaceStarts.shift());
                var name_remaining = String(this.name_list.shift());
                console.log(name_remaining, " is my name");
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
                        results: {
                            first: 0,
                            second: 0,
                            third: 0,
                            fourth: 0
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
        });
    }
    onLeave(client) {
        console.log(client.sessionId, "left race");
        this.availableRaceStarts.push(this.players[client.sessionId].slot);
        this.name_list.push(this.players[client.sessionId].name);
        const index = this.id_list.indexOf(client.sessionId);
        if (index != -1) {
            this.id_list.splice(index, 1);
        }
        ;
        delete this.players[client.sessionId];
        this.maxClients -= 1;
        console.log(" new client amt ", this.maxClients);
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
            this.id_name_list = [];
            for (const id of Object.keys(this.players)) {
                this.id_name_list.push([id, this.players[id].name]);
            }
            this.seed = Math.floor(Math.random() * 1000000);
            this.broadcast("seed", this.seed);
            this.broadcast("id_list", this.id_list);
            this.broadcast("id_with_name", this.id_name_list);
            const startTime = Date.now() + 3000;
            if (this.bossRequests.size > 0) {
                this.startNextBossRace();
            }
            else {
                this.broadcast("send_turtles", this.players);
            }
            this.broadcast("race_start", { startTime: startTime });
        }
    }
    standardizeResults() {
        var _a;
        const finalResults = [];
        var returnResults = { 1: [], 2: [], 3: [], 4: [] };
        for (let position = 0; position < this.maxClients; position++) {
            const votes = {};
            for (const result of this.raceResults.values()) {
                const racer = result[position + 1];
                votes[racer] = ((_a = votes[racer]) !== null && _a !== void 0 ? _a : 0) + 1;
            }
            let winningPlayer = "";
            let highestVotes = 0;
            for (const racer in votes) {
                if (votes[racer] > highestVotes) {
                    winningPlayer = racer;
                    highestVotes = votes[racer];
                }
            }
            finalResults[position] = winningPlayer;
        }
        console.log("FINAL RESULTS:", finalResults);
        this.lastResults = finalResults;
        for (let i = 0; i < finalResults.length; i++) {
            const placement = (i + 1);
            returnResults[placement].push(finalResults[i]);
        }
        console.log("STANDARDIZED RESULTS:", returnResults);
        return returnResults;
    }
    updateBossQueue() {
        this.bossQueue = [...this.bossRequests];
        if (this.bossQueue.length <= 1) {
            return;
        }
        ;
        this.bossQueue.sort((a, b) => {
            const playerA = this.players[a];
            const playerB = this.players[b];
            var placementA = 5;
            var placementB = 5;
            var counter = 1;
            for (const player_id of this.lastResults) {
                if (player_id == a) {
                    placementA = counter;
                }
                ;
                if (player_id == b) {
                    placementB = counter;
                }
                ;
                counter += 1;
            }
            return placementA - placementB;
        });
        this.broadcast("boss_queue_updated", { queue: this.bossQueue });
    }
    startNextBossRace() {
        if (this.bossRaceActive || this.bossRequests.size == 0)
            return;
        this.updateBossQueue();
        this.bossRaceActiveCounter = 0;
        const challengerId = this.bossQueue[0];
        this.bossRequests.delete(challengerId);
        this.bossRaceActive = true;
        for (const id of Object.keys(this.players)) {
            this.players[id].ready = false;
        }
        this.broadcast("send_boss_turtles", [this.players, this.players[challengerId].name, { "Rabbit": bosses.bosses["Rabbit"] }]);
    }
}
exports.RaceMatch = RaceMatch;
//# sourceMappingURL=RaceMatch.js.map