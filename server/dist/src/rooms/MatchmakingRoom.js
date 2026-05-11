import { Room } from "colyseus";
// import { MatchmakingState } from "../state/MatchmakingState.js";
import { timeStamp } from "node:console";
export class MatchmakingRoom extends Room {
    constructor() {
        super(...arguments);
        this.teams = [];
    }
    onCreate() {
        try {
            console.log("Matchmaking room created");
            this.onMessage("save_team", (client, message) => {
                console.log("Saving team: ", message.team);
                this.teams.push({
                    team: message.team,
                    timeStamp: Date.now()
                });
            });
            this.onMessage("find_match", (client) => {
                if (this.teams.length == 0) {
                    client.send("match_found", null);
                    return;
                }
                const randomIndex = Math.floor(Math.random() * this.teams.length);
                const opponent = this.teams[randomIndex];
                client.send("match_found", opponent.team);
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