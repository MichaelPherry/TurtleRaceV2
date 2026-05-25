import { Room } from "colyseus";
// import { MatchmakingState } from "../state/MatchmakingState.js";
import { timeStamp } from "node:console";

export function shuffle(t) {
    let currentIndex = t.length, randomIndex;
    while (currentIndex != 0){
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex--;

        [t[currentIndex], t[randomIndex]] = [t[randomIndex], t[currentIndex]];
    }
    return t;
}

export class MatchmakingRoom extends Room {
    constructor() {
        super(...arguments);
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
                if (this.turtles.length == 0) {
                    client.send("match_found", null);
                    return;
                }
                const randomIndex = Math.floor(Math.random() * this.turtles.length);
                const opponent = this.turtles[randomIndex];
                client.send("match_found", opponent.turt);
            });
            this.onMessage("battle_result", (client, message) => {
                console.log("Result: ", message.result);
            });
        }
        catch (e) {
            console.log("ROOM FAILED TO CREATE:", e);
        }
    }
    onJoin(client) {
        console.log(client.sessionId, "joined");
    }
    onLeave(client) {
        console.log(client.sessionId, "left");
    }
}
//# sourceMappingURL=MatchmakingRoom.js.map