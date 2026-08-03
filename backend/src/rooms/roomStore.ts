import type {
  CreateRoomResult,
  JoinRoomResult,
  LeaveRoomResult,
  Player,
  PlayerHealth,
  PlayerPosition,
  Room,
  SetPlayerPositionResult,
  SetReadyResult,
  StartGameResult
} from "./room.js";

export type RoomStoreOptions = {
  maxPlayers: number;
  createId: () => string;
  now: () => Date;
};

export class RoomStore {
  private readonly rooms = new Map<string, Room>();
  private readonly playerHealth = new Map<string, Map<string, PlayerHealthState>>();
  private readonly maxPlayers: number;
  private readonly createId: () => string;
  private readonly now: () => Date;

  public constructor(options: RoomStoreOptions) {
    this.maxPlayers = options.maxPlayers;
    this.createId = options.createId;
    this.now = options.now;
  }

  public createRoom(): CreateRoomResult {
    const room: Room = {
      id: this.createUniqueId(),
      status: "lobby",
      hostPlayerId: null,
      players: [],
      createdAt: this.now().toISOString()
    };

    this.rooms.set(room.id, room);

    return {
      room: cloneRoom(room)
    };
  }

  public getRoom(roomId: string): Room | null {
    const room = this.rooms.get(roomId);

    if (room === undefined) {
      return null;
    }

    return cloneRoom(room);
  }

  public joinRoom(roomId: string, playerName: string): JoinRoomResult {
    const room = this.rooms.get(roomId);

    if (room === undefined) {
      return {
        ok: false,
        reason: "room_not_found"
      };
    }

    if (room.status !== "lobby") {
      return {
        ok: false,
        reason: "game_already_started"
      };
    }

    if (room.players.length >= this.maxPlayers) {
      return {
        ok: false,
        reason: "room_full"
      };
    }

    const player: Player = {
      id: this.createUniqueId(),
      name: playerName,
      ready: false,
      connected: true
    };

    room.players.push(player);
    room.hostPlayerId ??= player.id;
    const healthByPlayer = this.playerHealth.get(roomId) ?? new Map<string, PlayerHealthState>();
    healthByPlayer.set(player.id, createPlayerHealth(player.id, room.players.length - 1, this.now()));
    this.playerHealth.set(roomId, healthByPlayer);

    return {
      ok: true,
      room: cloneRoom(room),
      player: clonePlayer(player)
    };
  }

  public leaveRoom(roomId: string, playerId: string): LeaveRoomResult {
    const room = this.rooms.get(roomId);

    if (room === undefined) {
      return {
        ok: false,
        reason: "room_not_found"
      };
    }

    const playerIndex = room.players.findIndex((player) => player.id === playerId);

    if (playerIndex === -1) {
      return {
        ok: false,
        reason: "player_not_found"
      };
    }

    room.players.splice(playerIndex, 1);
    this.playerHealth.get(roomId)?.delete(playerId);

    if (room.players.length === 0) {
      this.rooms.delete(roomId);
      this.playerHealth.delete(roomId);

      return {
        ok: true,
        roomDeleted: true,
        room: null
      };
    }

    if (room.hostPlayerId === playerId) {
      room.hostPlayerId = room.players[0].id;
    }

    return {
      ok: true,
      roomDeleted: false,
      room: cloneRoom(room)
    };
  }

  public setReady(roomId: string, playerId: string, ready: boolean): SetReadyResult {
    const room = this.rooms.get(roomId);

    if (room === undefined) {
      return {
        ok: false,
        reason: "room_not_found"
      };
    }

    const player = room.players.find((roomPlayer) => roomPlayer.id === playerId);

    if (player === undefined) {
      return {
        ok: false,
        reason: "player_not_found"
      };
    }

    player.ready = ready;

    return {
      ok: true,
      room: cloneRoom(room),
      player: clonePlayer(player)
    };
  }

  public startGame(roomId: string, playerId: string): StartGameResult {
    const room = this.rooms.get(roomId);

    if (room === undefined) {
      return {
        ok: false,
        reason: "room_not_found"
      };
    }

    const player = room.players.find((roomPlayer) => roomPlayer.id === playerId);

    if (player === undefined) {
      return {
        ok: false,
        reason: "player_not_found"
      };
    }

    if (room.hostPlayerId !== playerId) {
      return {
        ok: false,
        reason: "not_host"
      };
    }

    if (room.status === "in_game") {
      return {
        ok: false,
        reason: "already_started"
      };
    }

    const guests = room.players.filter((roomPlayer) => roomPlayer.id !== room.hostPlayerId);
    const guestsReady = guests.every((roomPlayer) => roomPlayer.ready);

    if (!guestsReady) {
      return {
        ok: false,
        reason: "players_not_ready"
      };
    }

    room.status = "in_game";

    return {
      ok: true,
      room: cloneRoom(room)
    };
  }

  public setPlayerPosition(
    roomId: string,
    playerId: string,
    position: PlayerPosition
  ): SetPlayerPositionResult {
    const room = this.rooms.get(roomId);

    if (room === undefined) {
      return {
        ok: false,
        reason: "room_not_found"
      };
    }

    if (room.status !== "in_game") {
      return {
        ok: false,
        reason: "game_not_started"
      };
    }

    const player = room.players.find((roomPlayer) => roomPlayer.id === playerId);

    if (player === undefined) {
      return {
        ok: false,
        reason: "player_not_found"
      };
    }

    player.position = {
      x: position.x,
      y: position.y
    };

    return {
      ok: true,
      room: cloneRoom(room),
      player: clonePlayer(player)
    };
  }

  public getPlayerHealth(roomId: string, playerId: string): PlayerHealth | null {
    return clonePlayerHealth(this.playerHealth.get(roomId)?.get(playerId));
  }

  public markPlayerShot(roomId: string, playerId: string, now = this.now()): boolean {
    const room = this.rooms.get(roomId);
    const state = this.playerHealth.get(roomId)?.get(playerId);

    if (room?.status !== "in_game" || state === undefined || state.defeated) {
      return false;
    }

    state.lastCombatAt = now.getTime();
    return true;
  }

  public applyPlayerDamage(
    roomId: string,
    playerId: string,
    damage: number,
    now = this.now()
  ): PlayerHealth | null {
    const room = this.rooms.get(roomId);
    const state = this.playerHealth.get(roomId)?.get(playerId);

    if (room?.status !== "in_game" || state === undefined || state.defeated) {
      return null;
    }

    state.health = Math.max(state.health - damage, 0);
    state.defeated = state.health === 0;
    state.lastCombatAt = now.getTime();
    state.lastRegenAt = now.getTime();
    return clonePlayerHealth(state);
  }

  public regeneratePlayers(now = this.now()): Array<{ roomId: string; health: PlayerHealth }> {
    const currentTime = now.getTime();
    const regenerated: Array<{ roomId: string; health: PlayerHealth }> = [];

    for (const [roomId, room] of this.rooms) {
      if (room.status !== "in_game") {
        continue;
      }

      const healthByPlayer = this.playerHealth.get(roomId) as Map<string, PlayerHealthState>;

      for (const state of healthByPlayer.values()) {
        if (state.defeated || state.health >= state.maxHealth) {
          state.lastRegenAt = currentTime;
          continue;
        }

        if (currentTime - state.lastCombatAt < REGEN_DELAY_MS) {
          state.lastRegenAt = currentTime;
          continue;
        }

        const elapsedSeconds = (currentTime - state.lastRegenAt) / 1000;
        const nextHealth = Math.min(state.health + state.regenRate * elapsedSeconds, state.maxHealth);

        if (nextHealth > state.health) {
          state.health = nextHealth;
          state.lastRegenAt = currentTime;
          regenerated.push({ roomId, health: clonePlayerHealth(state) as PlayerHealth });
        }
      }
    }

    return regenerated;
  }

  private createUniqueId(): string {
    let id = this.createId();

    while (this.rooms.has(id)) {
      id = this.createId();
    }

    return id;
  }
}

function cloneRoom(room: Room): Room {
  return {
    ...room,
    players: room.players.map(clonePlayer)
  };
}

function clonePlayer(player: Player): Player {
  return {
    ...player,
    position: player.position === undefined ? undefined : { ...player.position }
  };
}

type PlayerHealthState = PlayerHealth & {
  lastCombatAt: number;
  lastRegenAt: number;
  regenRate: number;
};

const REGEN_DELAY_MS = 4000;
const SHIP_MAX_HEALTH: [number, number, number, number] = [80, 100, 140, 90];
const SHIP_REGEN_RATE: [number, number, number, number] = [18, 14, 9, 12];

function createPlayerHealth(playerId: string, playerIndex: number, now: Date): PlayerHealthState {
  const index = playerIndex % SHIP_MAX_HEALTH.length;
  const maxHealth = SHIP_MAX_HEALTH[index];
  const timestamp = now.getTime();

  return {
    playerId,
    health: maxHealth,
    maxHealth,
    defeated: false,
    lastCombatAt: timestamp,
    lastRegenAt: timestamp,
    regenRate: SHIP_REGEN_RATE[index]
  };
}

function clonePlayerHealth(state: PlayerHealthState | undefined): PlayerHealth | null {
  if (state === undefined) {
    return null;
  }

  return {
    playerId: state.playerId,
    health: state.health,
    maxHealth: state.maxHealth,
    defeated: state.defeated
  };
}
