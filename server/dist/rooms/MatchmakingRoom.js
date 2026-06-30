"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MatchmakingRoom = exports.RaceLobby = void 0;
exports.shuffle = shuffle;
const colyseus_1 = require("colyseus");
class RaceLobby extends colyseus_1.Room {
    constructor() {
        super(...arguments);
        this.players = {};
    }
    onJoin(client) {
        //this.players[client.sessionId] = {team: null, ready: false}
        this.broadcast("player_count", this.clients.length);
    }
}
exports.RaceLobby = RaceLobby;
function shuffle(t) {
    let currentIndex = t.length, randomIndex;
    while (currentIndex != 0) {
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex--;
        [t[currentIndex], t[randomIndex]] = [t[randomIndex], t[currentIndex]];
    }
    return t;
}
class MatchmakingRoom extends colyseus_1.Room {
    constructor() {
        super();
        this.turtles = {};
        this.turtles = {
            "abcdef": { "leftArm": "fissile",
                "rightArm": "bear_trap",
                "head": null,
                "shell": null,
                "legs": null
            },
            "ghijkl": { "leftArm": "bear_trap",
                "rightArm": "fissile",
                "head": null,
                "shell": null,
                "legs": null
            },
            "mnopqr": { "leftArm": "mystery_item",
                "rightArm": "bear_trap",
                "head": null,
                "shell": null,
                "legs": null
            },
            "stuvwx": { "leftArm": "bear_trap",
                "rightArm": "bear_trap",
                "head": null,
                "shell": null,
                "legs": null
            },
            "yz1234": { "leftArm": null,
                "rightArm": null,
                "head": "propreller",
                "shell": null,
                "legs": null
            }
        };
    }
    ;
    onCreate() {
        try {
            console.log("Matchmaking room created");
            this.onMessage("save_turt", (client, message) => {
                console.log("Saving turt: ", message);
                this.turtles = Object.assign({}, message, this.turtles);
                //this.turtles[client.sessionId] = message;
                //#timeStamp: Date.now()
                var key_list = Object.keys(this.turtles);
                key_list = shuffle(key_list);
                key_list = key_list.slice(0, 4);
                console.log(key_list);
                var turtle_export = {
                    [key_list[0]]: this.turtles[key_list[0]],
                    [key_list[1]]: this.turtles[key_list[1]],
                    [key_list[2]]: this.turtles[key_list[2]],
                    [key_list[3]]: this.turtles[key_list[3]]
                };
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
    onJoin(client) {
        console.log(client.sessionId, "joined");
    }
    onLeave(client) {
        console.log(client.sessionId, "left");
    }
}
exports.MatchmakingRoom = MatchmakingRoom;
//# sourceMappingURL=MatchmakingRoom.js.map
//oh
//# sourceMappingURL=MatchmakingRoom.js.map