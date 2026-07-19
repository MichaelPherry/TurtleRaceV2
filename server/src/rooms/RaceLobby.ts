import { Room } from "colyseus";
import type { Client } from "colyseus";
import { matchMaker } from "colyseus";


type PlayerData = {
    ready: boolean;
    race_order: number;
    name: string
};

export class RaceLobby extends Room {

    maxClients = 4;
    availableRaceStarts = [1, 2, 3, 4]
    seed = 0;
    players: Record<string, PlayerData> = {};
    name_list: string[] = [];

    onCreate() {
        try {
            console.log("RaceLobby created");

            this.onMessage("ready", (client) => {
                this.players[client.sessionId].ready = true;
                console.log(client.sessionId, " is ready!")
                this.sendLobbyUpdate();
                this.checkStart();
            });
        }

        catch (e) {
            console.log("ROOM FAILED TO CREATE in Race Lobby:", e);
        }
    }

    onJoin(client: any, options: any) {

        console.log(options.player_name, "joined race");

        if (this.availableRaceStarts.length == 0) {
            client.leave();
            return
        }
        for (const player in this.players){
            if (this.players[player].name == options.player_name)
                options.player_name = client.sessionId
                }
                
        var slot = Number(this.availableRaceStarts.shift())

        //client.sessionId = options.player_name
        this.players[client.sessionId] = {
            ready: false,
            race_order: slot,
            name: options.player_name
        };
        client.send("session_id", client.sessionId)
        this.name_list.push(this.players[client.sessionId].name);
        this.sendLobbyUpdate();
    }

    onLeave(client: any) {
        console.log(client.sessionId, "left race");
        if (this.players[client.sessionId]) {
            this.availableRaceStarts.push(this.players[client.sessionId].race_order)
        }

        var index = this.name_list.indexOf(this.players[client.sessionId].name)
        if (index !== -1) {
            this.name_list.splice(index, 1);
        }

        delete this.players[client.sessionId];
        this.sendLobbyUpdate();
    }

    checkStart() {

        const allReady =
            Object.keys(this.players).length === this.maxClients &&
            Object.values(this.players).every(p => p.ready);

        if (!allReady) return;

        this.startRace();
    }

    sendLobbyUpdate() {
        const lobby = []
        for (const id in this.players){
            lobby.push({ready: this.players[id].ready, slot: this.players[id].race_order, name: this.players[id].name});
        }

        this.broadcast("lobby_update", lobby)
    }

    async startRace() {


        const raceRoom = await matchMaker.createRoom("raceMatch", [this.maxClients, this.name_list]);
        console.log(this.name_list)
        this.broadcast("load_race", { roomId: raceRoom.roomId})
        this.seed = Math.floor(Math.random() * 1000000);
        console.log("Starting race with seed:", this.seed);
        this.broadcast("seed", this.seed);
    }
}