import { Room, Client } from "colyseus";
import { MatchState } from "../schemas/MatchState";
import { RoundSystem } from "../systems/RoundSystem";
import { CombatSystem } from "../systems/CombatSystem";
import { PairingSystem } from "../systems/PairingSystem";

export class MatchRoom extends Room<MatchState> {

  maxClients = 8;

  onCreate(options: any) {
	this.setState(new MatchState());

	this.state.phase = "waiting";
	this.state.round = 0;
	this.state.timer = 0;

	this.onMessage("buy_unit", (client, data) => {
	  this.buyUnit(client, data.unitId);
	});

	this.onMessage("move_unit", (client, data) => {
	  this.moveUnit(client, data.from, data.to);
	});

	this.onMessage("ready_up", (client) => {
	  this.readyPlayer(client);
	});
  }

  onJoin(client: Client) {
	this.state.addPlayer(client.sessionId);

	if (this.clients.length == 8) {
	  this.startMatch();
	}
  }

  onLeave(client: Client) {
	this.state.markDisconnected(client.sessionId);
  }

  startMatch() {
	this.state.phase = "prep";
	this.state.round = 1;
	this.startPrepPhase();
  }

  startPrepPhase() {
	this.state.phase = "prep";
	this.state.timer = 30;

	this.clock.setInterval(() => {
	  this.state.timer--;

	  if (this.state.timer <= 0) {
		this.clock.clear();
		this.startCombatPhase();
	  }

	}, 1000);
  }

  startCombatPhase() {
	this.state.phase = "combat";

	const pairings = PairingSystem.generate(this.state);

	for (const pair of pairings) {
	  CombatSystem.resolve(this.state, pair[0], pair[1]);
	}

	this.clock.setTimeout(() => {
	  this.endRound();
	}, 8000);
  }

  endRound() {
	RoundSystem.applyRoundDamage(this.state);
	RoundSystem.removeDeadPlayers(this.state);

	if (this.state.activePlayers() <= 1) {
	  this.endMatch();
	  return;
	}

	this.state.round++;
	this.startPrepPhase();
  }

  endMatch() {
	this.state.phase = "finished";
  }

  buyUnit(client: Client, unitId: string) {
	// shop logic
  }

  moveUnit(client: Client, from: number, to: number) {
	// board logic
  }

  readyPlayer(client: Client) {
	// optional skip timer if all ready
  }
}
