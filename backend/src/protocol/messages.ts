export const CLIENT_MESSAGE_TYPES = [
  "join_room",
  "leave_room",
  "set_ready",
  "start_game",
  "player_position",
  "player_shot",
  "enemy_hit_player",
  "enemy_destroyed",
  "ping"
] as const;

export type ClientMessageType = (typeof CLIENT_MESSAGE_TYPES)[number];

export type JoinRoomMessage = {
  type: "join_room";
  playerName: string;
};

export type LeaveRoomMessage = {
  type: "leave_room";
};

export type SetReadyMessage = {
  type: "set_ready";
  ready: boolean;
};

export type StartGameMessage = {
  type: "start_game";
};

export type PlayerPosition = {
  x: number;
  y: number;
};

export type PlayerPositionMessage = {
  type: "player_position";
  position: PlayerPosition;
};

export type PlayerShot = {
  x: number;
  y: number;
  damage: number;
  range: number;
};

export type PlayerShotMessage = {
  type: "player_shot";
  shot: PlayerShot;
};

export type EnemyHitPlayerMessage = {
  type: "enemy_hit_player";
  playerId: string;
  damage: number;
};

export type EnemyDestroyedMessage = {
  type: "enemy_destroyed";
  enemyId: string;
};

export type PingMessage = {
  type: "ping";
  timestamp: number;
};

export type ClientMessage =
  | JoinRoomMessage
  | LeaveRoomMessage
  | SetReadyMessage
  | StartGameMessage
  | PlayerPositionMessage
  | PlayerShotMessage
  | EnemyHitPlayerMessage
  | EnemyDestroyedMessage
  | PingMessage;

export type ProtocolError = {
  message: string;
};

export type ParseClientMessageResult =
  | {
      ok: true;
      message: ClientMessage;
    }
  | {
      ok: false;
      error: ProtocolError;
    };

export function parseClientMessage(raw: string): ParseClientMessageResult {
  let parsed: unknown;

  try {
    parsed = JSON.parse(raw) as unknown;
  } catch {
    return invalid("Message must be valid JSON");
  }

  if (!isRecord(parsed)) {
    return invalid("Message must be an object");
  }

  if (typeof parsed.type !== "string") {
    return invalid("Message type is required");
  }

  switch (parsed.type) {
    case "join_room":
      return parseJoinRoomMessage(parsed);
    case "leave_room":
      return { ok: true, message: { type: "leave_room" } };
    case "set_ready":
      return parseSetReadyMessage(parsed);
    case "start_game":
      return { ok: true, message: { type: "start_game" } };
    case "player_position":
      return parsePlayerPositionMessage(parsed);
    case "player_shot":
      return parsePlayerShotMessage(parsed);
    case "enemy_hit_player":
      return parseEnemyHitPlayerMessage(parsed);
    case "enemy_destroyed":
      return parseEnemyDestroyedMessage(parsed);
    case "ping":
      return parsePingMessage(parsed);
    default:
      return invalid(`Unsupported message type: ${parsed.type}`);
  }
}

function parseJoinRoomMessage(value: Record<string, unknown>): ParseClientMessageResult {
  if (typeof value.playerName !== "string") {
    return invalid("playerName is required");
  }

  const playerName = value.playerName.trim();

  if (playerName.length === 0) {
    return invalid("playerName cannot be empty");
  }

  if (playerName.length > 24) {
    return invalid("playerName cannot exceed 24 characters");
  }

  return {
    ok: true,
    message: {
      type: "join_room",
      playerName
    }
  };
}

function parseSetReadyMessage(value: Record<string, unknown>): ParseClientMessageResult {
  if (typeof value.ready !== "boolean") {
    return invalid("ready must be a boolean");
  }

  return {
    ok: true,
    message: {
      type: "set_ready",
      ready: value.ready
    }
  };
}

function parsePlayerPositionMessage(value: Record<string, unknown>): ParseClientMessageResult {
  if (!isRecord(value.position)) {
    return invalid("position is required");
  }

  const { x, y } = value.position;

  if (typeof x !== "number" || !Number.isFinite(x)) {
    return invalid("position.x must be a finite number");
  }

  if (typeof y !== "number" || !Number.isFinite(y)) {
    return invalid("position.y must be a finite number");
  }

  return {
    ok: true,
    message: {
      type: "player_position",
      position: {
        x,
        y
      }
    }
  };
}

function parsePlayerShotMessage(value: Record<string, unknown>): ParseClientMessageResult {
  if (!isRecord(value.shot)) {
    return invalid("shot is required");
  }

  const { x, y, damage, range } = value.shot;

  if (typeof x !== "number" || !Number.isFinite(x)) {
    return invalid("shot.x must be a finite number");
  }

  if (typeof y !== "number" || !Number.isFinite(y)) {
    return invalid("shot.y must be a finite number");
  }

  if (typeof damage !== "number" || !Number.isFinite(damage) || damage <= 0) {
    return invalid("shot.damage must be a positive finite number");
  }

  if (typeof range !== "number" || !Number.isFinite(range) || range <= 0) {
    return invalid("shot.range must be a positive finite number");
  }

  return {
    ok: true,
    message: {
      type: "player_shot",
      shot: {
        x,
        y,
        damage,
        range
      }
    }
  };
}

function parseEnemyDestroyedMessage(value: Record<string, unknown>): ParseClientMessageResult {
  if (typeof value.enemyId !== "string") {
    return invalid("enemyId is required");
  }

  const enemyId = value.enemyId.trim();

  if (enemyId.length === 0) {
    return invalid("enemyId cannot be empty");
  }

  return {
    ok: true,
    message: {
      type: "enemy_destroyed",
      enemyId
    }
  };
}

function parseEnemyHitPlayerMessage(value: Record<string, unknown>): ParseClientMessageResult {
  if (typeof value.playerId !== "string" || value.playerId.trim().length === 0) {
    return invalid("playerId is required");
  }

  if (typeof value.damage !== "number" || !Number.isFinite(value.damage) || value.damage <= 0) {
    return invalid("damage must be a positive finite number");
  }

  return {
    ok: true,
    message: {
      type: "enemy_hit_player",
      playerId: value.playerId.trim(),
      damage: value.damage
    }
  };
}

function parsePingMessage(value: Record<string, unknown>): ParseClientMessageResult {
  if (typeof value.timestamp !== "number" || !Number.isFinite(value.timestamp)) {
    return invalid("timestamp must be a finite number");
  }

  return {
    ok: true,
    message: {
      type: "ping",
      timestamp: value.timestamp
    }
  };
}

function invalid(message: string): ParseClientMessageResult {
  return {
    ok: false,
    error: {
      message
    }
  };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
