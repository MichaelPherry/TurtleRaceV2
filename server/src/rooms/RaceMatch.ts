import { Room } from "colyseus";
import type { Client } from "colyseus";

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
        //stock1: Int16Array | 0;
        //stock2: Int16Array | 0;
        //stock3: Int16Array | 0;
        //stock4: Int16Array | 0;
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

export class RaceMatch extends Room {

    players: Record<string, Player> = {};
    placements: string[] = [];
    maxClients: number = 4;
    availableRaceStarts = [1, 2, 3, 4];
    id_list: string[] = [];
    perm_name_list: string[] = [];
    id_name_list: Array<string>[] = [];
    name_list: string[] = [];
    seed: number = 0;

    onCreate(options: any) {
        try{
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
            this.players[client.sessionId].build.name = turtle_build["name"]
            this.players[client.sessionId].ready = true;
            var counter = 0
            for (const id of Object.keys(this.players)){
                if (this.players[id].ready == true){
                    counter += 1
                }
            }
            if (counter == 4)
            {
                console.log("wooo")
                for (const id of Object.keys(this.players)){
                    this.id_name_list.push([id, this.players[id].name])
                }

                this.broadcast("id_with_name", this.id_name_list)
                this.broadcast("send_turtles", this.players)

                const startTime = Date.now() + 3000;
                this.broadcast("race_start", {startTime: startTime});
            }
        });

        this.onMessage("Unready", (client) => {
            this.players[client.sessionId].ready = false;    
        });

        this.onMessage("enter_shop", (client, message) => {
            console.log(this.perm_name_list)
            this.broadcast("id_list",this.id_list)
            this.seed = Math.floor(Math.random() * 1000000);
            console.log("New seed:", this.seed);
            this.broadcast("seed", this.seed);
        });
        }

        catch (e) {
            console.log("ROOM FAILED TO CREATE in Race Match:", e);
        }
    }

        onJoin(client: any) {
        try{
            var race_slot = Number(this.availableRaceStarts.shift());
            var name_remaining = String(this.name_list.shift());
            console.log(name_remaining)
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
        this.id_list.push(client.sessionId)
        }

        catch (e) {
            console.log("ROOM FAILED TO CREATE in Join Race Match:", e);
        }

    }

     onLeave(client: any) {
        console.log(client.sessionId, "left race");
        if (this.players[client.sessionId]) {
            this.availableRaceStarts.push(this.players[client.sessionId].slot)
            this.name_list.push(this.players[client.sessionId].name)
        }
        delete this.players[client.sessionId];
     }
}

