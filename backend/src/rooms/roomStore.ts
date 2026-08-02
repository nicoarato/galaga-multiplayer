import type {
  CreateRoomResult,
  JoinRoomResult,
  LeaveRoomResult,
  Player,
  Room,
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

    if (room.players.length === 0) {
      this.rooms.delete(roomId);

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
    ...player
  };
}
