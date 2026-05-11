import { Client } from "@colyseus/sdk";
const client = new Client("ws://localhost:2567");
(async () => {
    try {
        console.log("Connecting...");
        const room = await client.joinOrCreate("matchmaking");
        console.log("Connected!");
        console.log("Room ID:", room.roomId);
    }
    catch (e) {
        console.error("JOIN FAILED:", e);
    }
})();
//# sourceMappingURL=test.js.map