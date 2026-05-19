import { Room } from "colyseus";
import type { Client } from "colyseus";
// import { MatchmakingState } from "../state/MatchmakingState.js";
import { timeStamp } from "node:console";

export class MatchmakingRoom extends Room<any> {

    turtles: any[] = [];

    onCreate()  {
        try{
            console.log("Matchmaking room created");
            console.log("every time?");

            this.onMessage("save_turt", (client, message) => {
                console.log("Saving turt: ", message.turt);

                this.turtles.push({
                    turt: message.turt,
                    timeStamp: Date.now()

                });

                client.send("turt_saved", {
                    success: true
                });
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
        
        catch(e) {
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