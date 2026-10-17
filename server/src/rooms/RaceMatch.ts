import { Room } from "colyseus";
import type { Client } from "colyseus";
import { bossBuilds, botBuilds } from "../bots/botBuilds.js";
import { bot_list } from "../bots/botBuilds.js";
import { PassThrough } from "node:stream";

type Turtle = {
    items : {
        leftArm: string | null;
        rightArm: string | null;
        head: string | null;
        shell: string | null;
        legs: string | null;
    },

    base_stats : {
        acceleration: Float16Array | 5.0;
        resilience: Float16Array | 0.1;
        max_speed: Float16Array | 300.0;
        fire_rate: Float16Array | 1.0;
        projectile_speed: Float16Array | 1.0;
        luck: Float16Array | 1.0;
    },

    econ : {
        gold: Int16Array | 10;
        stock1: Int16Array | 0;
        stock2: Int16Array | 0;
        stock3: Int16Array | 0;
        stock4: Int16Array | 0;
    },

    results: {
        first: number | 0;
        second: number | 0;
        third: number | 0;
        fourth: number| 0;
    },

    name : string;
};

type Player = {
    build: Turtle;
    finished: boolean;
    placement: number | null;
    ready: boolean;
    slot: number;
    name: string;
};

const bosses = new bossBuilds();

export class RaceMatch extends Room {

    private initialized!: Promise<void>;
    private initialize!: () => void;

    players: Record<string, Player> = {};
    placements: string[] = [];
    maxClients: number = 4;
    availableRaceStarts = [1, 2, 3, 4];
    round: number = 0;
    roundResults: Record<number, string[]> = {};
    id_list: string[] = [];
    perm_name_list: string[] = [];
    id_name_list: Array<string>[] = [];
    name_list: string[] = [];
    seed: number = 0;
    seeds_boss: string = "";
    wins = new Map<string, number>();
    raceResults = new Map<string, string[]>();
    lastResults: string[] = [];
    bossRequests = new Set<string>();
    bossRaceActive = false;
    bossRaceActiveCounter = 0;
    bossQueue: string[] = [];

    onCreate(options: any) {
        try{
        this.initialized = new Promise((resolve) => {
        this.initialize = resolve;
        });
        console.log("RACE MATCH OPTIONS:", options);

        this.maxClients = options.maxClients;
        this.name_list = options.nameList.slice();
        this.perm_name_list = options.nameList.slice();
        this.seeds_boss = options.end_boss
        console.log("set up finished");
        console.log("NAME LIST ", this.name_list)
        this.initialize();

        this.onMessage("submit_turtle", (client, turtle_build) => {
            this.players[client.sessionId].build.items = turtle_build["items"];
            this.players[client.sessionId].build.base_stats = turtle_build["base_stats"];
            this.players[client.sessionId].build.econ = turtle_build["econ"];
            console.log(this.players[client.sessionId].name + " " + turtle_build);
            this.players[client.sessionId].name = turtle_build["name"];
            this.players[client.sessionId].build.name = turtle_build["name"]
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
                let num_to_word: "first" | "second" | "third" | "fourth" = "fourth";
                for (var placement of Object.keys(results)){
                    if (Number(placement) == 1){num_to_word = "first"};
                    if (Number(placement) == 2){num_to_word = "second"};
                    if (Number(placement) == 3){num_to_word = "third"};
                    if (Number(placement) == 4){num_to_word = "fourth"};
                    var racer = message[placement][0];
                    console.log("message: ", message);
                    console.log("placement:", placement);
                    console.log("racer:", racer);
                    console.log("players:", this.players);
                    console.log("players:", this.players[racer].build.results);

                    this.players[racer].build.results[num_to_word] += 1;
                };
                this.broadcast("round_results", [this.round, this.roundResults]);
            };
        })

        this.onMessage("request_boss_race", (client, message) => {
            const player = this.players[client.sessionId];
            if (this.bossRequests.has(client.sessionId)) return;
            this.bossRequests.add(client.sessionId);
            this.updateBossQueue();
            //this.broadcast("race_start", {startTime: startTime});
        })

        this.onMessage("boss_not_active", (client, message) => {
            this.bossRaceActiveCounter += 1;
            if (this.bossRaceActiveCounter >= this.maxClients) {this.bossRaceActive = false};  
        })

        this.onMessage("start_race_after_boss", (client, message) => {
            this.players[client.sessionId].ready = true
            this.bossRaceActive = false;  
            this.raceStart(client);
        })

        this.onMessage("keepingServerUp", (client, message) => {
            void 0;
        });
        }

        catch (e) {
            console.log("ROOM FAILED TO CREATE in Race Match:", e);
        }
    }

    async onJoin(client: any) {
        await this.initialized;
        try{
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
                    gold: 10,
                    stock1: 0,
                    stock2: 0,
                    stock3: 0,
                    stock4: 0
                },

                results: {
                    first: 0,
                    second: 0,
                    third:  0,
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
        this.id_list.push(client.sessionId)
        }

        catch (e) {
            console.log("ROOM FAILED TO CREATE in Join Race Match:", e);
        }

    }

     onLeave(client: any) {
        console.log(client.sessionId, "left race");
        this.availableRaceStarts.push(this.players[client.sessionId].slot);
        this.name_list.push(this.players[client.sessionId].name);
        const index = this.id_list.indexOf(client.sessionId);
        if (index != -1){this.id_list.splice(index, 1)};
        delete this.players[client.sessionId];
        this.maxClients -= 1;
        console.log(" new client amt ", this.maxClients);
        this.raceStart(client);
     }

     raceStart(client: any){
        var counter = 0
        for (const id of Object.keys(this.players)){
            if (this.players[id].ready == true){
                counter += 1
            }
        }

        if (counter >= this.maxClients)
        {

            if (this.round <= 1){
                var companies = ["Inc", "Corp", "Co", "LLC"];
                var id_stock_list = [];
                var counter = 0;
                for (const id of Object.keys(this.players)){
                    id_stock_list.push([id, this.players[id].name + " " + companies[counter]])
                    counter += 1
                }
                this.broadcast("id_with_stock", id_stock_list)
            }

            this.id_name_list = [];
            for (const id of Object.keys(this.players)){
                this.id_name_list.push([id, this.players[id].name])
            }

            this.seed = Math.floor(Math.random() * 1000000);
            this.broadcast("seed", this.seed);
            this.broadcast("id_list", this.id_list)
            this.broadcast("id_with_name", this.id_name_list)
            const startTime = Date.now() + 3000;

            if (this.bossRequests.size > 0) {this.startNextBossRace()}
            else {this.broadcast("send_turtles", this.players);}
            this.broadcast("race_start", {startTime: startTime});
        }
     }

     standardizeResults(){
        const finalResults: string[] = [];
        var returnResults: Record<1 | 2 | 3 | 4, string[]> = {1: [], 2: [], 3: [], 4: []};

        for(let position = 0; position < this.maxClients; position++) {
            const votes: Record<string, number> = {};
            
            for (const result of this.raceResults.values()) {
                const racer = result[position + 1];
                votes[racer] = (votes[racer] ?? 0) + 1;
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
        this.round += 1;
        this.roundResults[this.round] = finalResults;
        for (let i = 0; i < finalResults.length; i++) {
            const placement = (i + 1) as 1 | 2 | 3 | 4;
            returnResults[placement].push(finalResults[i]);
        }

        console.log("STANDARDIZED RESULTS:", returnResults);

        return returnResults;
    }

    updateBossQueue() {
        this.bossQueue = [...this.bossRequests];
        if (this.bossQueue.length <= 1) {return};
        this.bossQueue.sort((a, b) => {
            const playerA = this.players[a];
            const playerB = this.players[b];
            
            var placementA = 5
            var placementB = 5
            var counter = 1;
            for (const player_id of this.lastResults){
                if (player_id == a){placementA = counter};
                if (player_id == b){placementB = counter};
                counter += 1
            }

            return placementA - placementB
        });

        this.broadcast("boss_queue_updated", {queue: this.bossQueue})
    }

    startNextBossRace() {
        if (this.bossRaceActive || this.bossRequests.size == 0) return;

        this.updateBossQueue();
        this.bossRaceActiveCounter = 0;
        const challengerId = this.bossQueue[0];
        this.bossRequests.delete(challengerId);

        this.bossRaceActive = true;
        for (const id of Object.keys(this.players)){
            this.players[id].ready = false;
        }
        this.broadcast("send_boss_turtles", [this.players, this.players[challengerId].name, {"Rabbit": bosses.bosses["Rabbit"]}]);
    }
}