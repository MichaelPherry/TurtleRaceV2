import { Room } from "colyseus";
import type { Client } from "colyseus";
import { botBuilds } from "../bots/botBuilds.js";
import { bot_list } from "../bots/botBuilds.js";
import { PassThrough } from "stream";

type Turtle = {
    items : {
        leftArm: string | null;
        rightArm: string | null;
        head: string | null;
        shell: string | null;
        legs: string | null;
    },

    base_stats : {
        acceleration: number | 5.0;
        resilience: number | 0.1;
        max_speed: number | 300.0;
        fire_rate: number | 1.0;
        projectile_speed: number | 1.0;
        luck: number | 1.0;
    },

    econ : {
        gold: number | 10;
        //stock1: Int16Array | 0;
        //stock2: Int16Array | 0;
        //stock3: Int16Array | 0;
        //stock4: Int16Array | 0;
    }
};

type Player = {
    build: Turtle;
    finished: boolean;
    placement: number | null;
    ready: boolean;
    slot: number;
    name: string;
};

const builds = new botBuilds();

export class RaceMatchLocal extends Room {

    players: Record<string, Player> = {};
    placements: string[] = [];
    maxClients: number = 4;
    availableRaceStarts = [1, 2, 3, 4];
    id_list: string[] = [];
    perm_name_list: string[] = [];
    id_name_list: Array<string>[] = [];
    name_list: string[] = [];
    seed: number = 0;
    round: number = 0;
    availableBots = [...bot_list]
    cpu1: string = "";
    cpu2: string = "";
    cpu3: string = "";


    onCreate(options: any) {
        try{
        console.log("singleplayer");
        this.maxClients = options[0];
        console.log(options[1] + " name");
        this.name_list = options[1];
        this.perm_name_list = options[1].slice();
        this.onMessage("submit_turtle", (client, turtle_build) => {
            this.players[client.sessionId].build.items = turtle_build["items"];
            this.players[client.sessionId].build.base_stats = turtle_build["base_stats"];
            this.players[client.sessionId].build.econ = turtle_build["econ"];

            this.round += 1;
            if (this.round > 3) {this.round = 3;};

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

        onJoin(client: any) {
        try{
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

    }

     onLeave(client: any) {
        console.log(client.sessionId, "left race");
        this.availableRaceStarts.push(this.players[client.sessionId].slot)
        this.name_list.push(this.players[client.sessionId].name)
        const index = this.id_list.indexOf(client.session_id.name);
        if (index != -1){this.id_list.splice(index, 1)};
        delete this.players[client.sessionId];
        this.maxClients -= 1;
        console.log(" new clients and players ", [this.maxClients, this.players]);
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
                console.log("wooo")
                for (const id of Object.keys(this.players)){
                    this.id_name_list.push([id, this.players[id].name])
                }
 
                this.seed = Math.floor(Math.random() * 1000000);
                this.broadcast("seed", this.seed);
                this.broadcast("id_list", this.id_list)
                this.broadcast("id_with_name", this.id_name_list)
                this.broadcast("send_turtles", this.players)

                const startTime = Date.now() + 3000;
                this.broadcast("race_start", {startTime: startTime});
            }
     }
}
