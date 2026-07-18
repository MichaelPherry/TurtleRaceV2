import { Room } from "colyseus";
import type { Client } from "colyseus";

type Turtle = {
    leftArm: string | null;
    rightArm: string | null;
    head: string | null;
    shell: string | null;
    legs: string | null;
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
    name_list: string[] = [];
    seed: number = 0;

    onCreate(options: any) {
        try{
        console.log("beg " + options);
        this.maxClients = options[0];
        this.name_list = options[1];
        this.perm_name_list = options[1].slice();
        this.onMessage("submit_turtle", (client, turtle_build) => {
            this.players[client.sessionId].build = turtle_build;
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
            this.broadcast("name_list", this.perm_name_list)
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
            this.players[client.sessionId] = {
            build:  {
                leftArm: null,
                rightArm: null,
                head: null,
                shell: null,
                legs: null
            },
            slot: race_slot,
            finished: false,
            placement: null,
            ready: false,
            name: name_remaining
        };
        client.sessionId = this.players[client.sessionId].name
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

