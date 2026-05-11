import { Room } from "colyseus";
import type { Client } from "colyseus";
export declare class MatchmakingRoom extends Room<any> {
    teams: any[];
    onCreate(): void;
    onJoin(client: Client): void;
    onLeave(client: Client): void;
}
//# sourceMappingURL=MatchmakingRoom.d.ts.map