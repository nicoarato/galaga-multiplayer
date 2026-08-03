export type RoomStatus = "lobby" | "in_game";

export type PlayerPosition = {
  x: number;
  y: number;
};

export type Player = {
  id: string;
  name: string;
  ready: boolean;
  connected: boolean;
  position?: PlayerPosition;
};

export type Room = {
  id: string;
  status: RoomStatus;
  hostPlayerId: string | null;
  players: Player[];
  createdAt: string;
};

export type CreateRoomResult = {
  room: Room;
};

export type JoinRoomResult =
  | {
      ok: true;
      room: Room;
      player: Player;
    }
  | {
      ok: false;
      reason: "room_not_found" | "room_full" | "game_already_started";
    };

export type LeaveRoomResult =
  | {
      ok: true;
      roomDeleted: boolean;
      room: Room | null;
    }
  | {
      ok: false;
      reason: "room_not_found" | "player_not_found";
    };

export type SetReadyResult =
  | {
      ok: true;
      room: Room;
      player: Player;
    }
  | {
      ok: false;
      reason: "room_not_found" | "player_not_found";
    };

export type StartGameResult =
  | {
      ok: true;
      room: Room;
    }
  | {
      ok: false;
      reason:
        | "room_not_found"
        | "player_not_found"
        | "not_host"
        | "already_started"
        | "players_not_ready";
    };

export type SetPlayerPositionResult =
  | {
      ok: true;
      room: Room;
      player: Player;
    }
  | {
      ok: false;
      reason: "room_not_found" | "player_not_found" | "game_not_started";
    };
