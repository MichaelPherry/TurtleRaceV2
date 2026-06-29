import { Room } from "colyseus";
import type { Client } from "colyseus";

import { timeStamp } from "node:console";
type Turtle = {
    leftArm: string | null;
    rightArm: string | null;
    head: string | null;
    shell: string | null;
    legs: string | null;
};

export class RaceLobby extends Room {
    players = {}

    onJoin(client: any) {

        //this.players[client.sessionId] = {team: null, ready: false}
        this.broadcast("player_count", this.clients.length)
    }
}

export function shuffle(t: any) {
    let currentIndex = t.length, randomIndex;
    while (currentIndex != 0){
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex--;

        [t[currentIndex], t[randomIndex]] = [t[randomIndex], t[currentIndex]];
    }
    return t;
}

export class MatchmakingRoom extends Room {
    turtles: Record<string, Turtle> = {};
    constructor() {
        super();
        this.turtles = {
        "abcdef" : {"leftArm" : "fissile",
        "rightArm" : "bear_trap",
        "head" : null,
        "shell" : null,
        "legs" : null
        },

        "ghijkl" : {"leftArm" : "bear_trap",
        "rightArm" : "fissile",
        "head" : null,
        "shell" : null,
        "legs" : null
        },
          
        "mnopqr" : {"leftArm" : "mystery_item",
        "rightArm" : "bear_trap",
        "head" : null,
        "shell" : null,
        "legs" : null
        },

        "stuvwx" : {"leftArm" : "bear_trap",
        "rightArm" : "bear_trap",
        "head" : null,
        "shell" : null,
        "legs" : null
        },

        "yz1234": {"leftArm" : null,
        "rightArm" : null,
        "head" : "propreller",
        "shell" : null,
        "legs" : null
        }
    }
};
    
    
    onCreate() {
        try {
            console.log("Matchmaking room created");
            this.onMessage("save_turt", (client, message) => {
                console.log("Saving turt: ", message);
                this.turtles = Object.assign({}, message, this.turtles);
                //this.turtles[client.sessionId] = message;
                //#timeStamp: Date.now()

                var key_list = Object.keys(this.turtles);
                key_list = shuffle(key_list)
                key_list = key_list.slice(0, 4);
                console.log(key_list)
                var turtle_export = {
                    [key_list[0]] : this.turtles[key_list[0]], 
                    [key_list[1]] : this.turtles[key_list[1]], 
                    [key_list[2]] : this.turtles[key_list[2]], 
                    [key_list[3]] : this.turtles[key_list[3]]
                }
                client.send("turt_saved  ", turtle_export);
                console.log("sent!");
            });
            this.onMessage("find_match", (client) => {
                if (Object.keys(this.turtles).length == 0) {
                    client.send("match_found", null);
                    return;
                }
                const randomIndex = Math.floor(Math.random() * Object.keys(this.turtles).length);
                const opponent = this.turtles[randomIndex];
                client.send("match_found", opponent);
            });
            this.onMessage("battle_result", (client, message) => {
                console.log("Result: ", message.result);
            });
        }
        catch (e) {
            console.log("ROOM FAILED TO CREATE:", e);
        }
    }
    onJoin(client: Client) {
        console.log(client.sessionId, "joined");
    }
    onLeave(client: Client) {
        console.log(client.sessionId, "left");
    }
}
//# sourceMappingURL=MatchmakingRoom.js.map
//oh