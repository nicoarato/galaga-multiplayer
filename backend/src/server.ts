import { createServer } from "node:http";
import type { IncomingMessage, ServerResponse } from "node:http";
import { WebSocketServer, type RawData, type WebSocket } from "ws";

import { createId } from "./ids.js";
import { parseClientMessage } from "./protocol/messages.js";
import { RoomStore } from "./rooms/roomStore.js";

const port = Number.parseInt(process.env.PORT ?? "3000", 10);
const frontendUrl = process.env.FRONTEND_URL ?? "http://localhost:8080";
const roomStore = new RoomStore({
  maxPlayers: 4,
  createId,
  now: () => new Date()
});
const roomSockets = new Map<string, Set<ClientConnection>>();

type ClientConnection = {
  socket: WebSocket;
  roomId: string;
  playerId: string | null;
};

const server = createServer((request, response) => {
  setCorsHeaders(response);

  if (request.method === "OPTIONS") {
    response.writeHead(204);
    response.end();
    return;
  }

  if (request.method === "GET" && request.url === "/health") {
    sendJson(response, 200, { ok: true });
    return;
  }

  if (request.method === "POST" && request.url === "/api/rooms") {
    const { room } = roomStore.createRoom();
    sendJson(response, 201, {
      roomId: room.id,
      joinPath: `/room/${room.id}`,
      room
    });
    return;
  }

  const roomMatch = request.url?.match(/^\/api\/rooms\/([^/]+)$/);

  if (request.method === "GET" && roomMatch?.[1] !== undefined) {
    const room = roomStore.getRoom(roomMatch[1]);

    if (room === null) {
      sendJson(response, 404, { error: "room_not_found" });
      return;
    }

    sendJson(response, 200, { room });
    return;
  }

  sendJson(response, 404, { error: "not_found" });
});

const webSocketServer = new WebSocketServer({ noServer: true });

server.on("upgrade", (request, socket, head) => {
  const roomId = getWebSocketRoomId(request);

  if (roomId === null) {
    socket.destroy();
    return;
  }

  webSocketServer.handleUpgrade(request, socket, head, (webSocket) => {
    webSocketServer.emit("connection", webSocket, request, roomId);
  });
});

webSocketServer.on("connection", (socket: WebSocket, _request: IncomingMessage, roomId: string) => {
  const connection: ClientConnection = {
    socket,
    roomId,
    playerId: null
  };

  addConnection(connection);

  socket.on("message", (data) => {
    handleSocketMessage(connection, rawSocketMessageToString(data));
  });

  socket.on("close", () => {
    handleSocketClose(connection);
  });
});

server.listen(port, "0.0.0.0", () => {
  console.log(`Backend listening on http://0.0.0.0:${String(port)}`);
});

function handleSocketMessage(connection: ClientConnection, rawMessage: string): void {
  const parsed = parseClientMessage(rawMessage);

  if (!parsed.ok) {
    sendSocket(connection.socket, "error", parsed.error);
    return;
  }

  switch (parsed.message.type) {
    case "join_room": {
      const result = roomStore.joinRoom(connection.roomId, parsed.message.playerName);

      if (!result.ok) {
        sendSocket(connection.socket, "error", { reason: result.reason });
        return;
      }

      connection.playerId = result.player.id;
      broadcastRoom(connection.roomId, "room_state", { room: result.room });
      return;
    }
    case "leave_room":
      handleSocketClose(connection);
      connection.socket.close();
      return;
    case "set_ready": {
      if (connection.playerId === null) {
        sendSocket(connection.socket, "error", { reason: "player_not_joined" });
        return;
      }

      const result = roomStore.setReady(connection.roomId, connection.playerId, parsed.message.ready);

      if (!result.ok) {
        sendSocket(connection.socket, "error", { reason: result.reason });
        return;
      }

      broadcastRoom(connection.roomId, "room_state", { room: result.room });
      return;
    }
    case "start_game": {
      if (connection.playerId === null) {
        sendSocket(connection.socket, "error", { reason: "player_not_joined" });
        return;
      }

      const result = roomStore.startGame(connection.roomId, connection.playerId);

      if (!result.ok) {
        sendSocket(connection.socket, "error", { reason: result.reason });
        return;
      }

      broadcastRoom(connection.roomId, "game_started", { room: result.room });
      return;
    }
    case "player_position": {
      if (connection.playerId === null) {
        sendSocket(connection.socket, "error", { reason: "player_not_joined" });
        return;
      }

      const result = roomStore.setPlayerPosition(connection.roomId, connection.playerId, parsed.message.position);

      if (!result.ok) {
        sendSocket(connection.socket, "error", { reason: result.reason });
        return;
      }

      broadcastRoom(connection.roomId, "room_state", { room: result.room });
      return;
    }
    case "player_shot": {
      if (connection.playerId === null) {
        sendSocket(connection.socket, "error", { reason: "player_not_joined" });
        return;
      }

      const room = roomStore.getRoom(connection.roomId);

      if (room === null) {
        sendSocket(connection.socket, "error", { reason: "room_not_found" });
        return;
      }

      if (room.status !== "in_game") {
        sendSocket(connection.socket, "error", { reason: "game_not_started" });
        return;
      }

      broadcastRoom(connection.roomId, "player_shot", {
        playerId: connection.playerId,
        shot: parsed.message.shot
      });
      return;
    }
    case "ping":
      sendSocket(connection.socket, "pong", { timestamp: parsed.message.timestamp });
      return;
  }
}

function handleSocketClose(connection: ClientConnection): void {
  removeConnection(connection);

  if (connection.playerId === null) {
    return;
  }

  const result = roomStore.leaveRoom(connection.roomId, connection.playerId);
  connection.playerId = null;

  if (result.ok && !result.roomDeleted && result.room !== null) {
    broadcastRoom(connection.roomId, "room_state", { room: result.room });
  }
}

function addConnection(connection: ClientConnection): void {
  const connections = roomSockets.get(connection.roomId) ?? new Set<ClientConnection>();
  connections.add(connection);
  roomSockets.set(connection.roomId, connections);
}

function removeConnection(connection: ClientConnection): void {
  const connections = roomSockets.get(connection.roomId);

  if (connections === undefined) {
    return;
  }

  connections.delete(connection);

  if (connections.size === 0) {
    roomSockets.delete(connection.roomId);
  }
}

function broadcastRoom(roomId: string, type: string, payload: Record<string, unknown>): void {
  const connections = roomSockets.get(roomId);

  if (connections === undefined) {
    return;
  }

  for (const connection of connections) {
    sendSocket(connection.socket, type, payload);
  }
}

function sendSocket(socket: WebSocket, type: string, payload: Record<string, unknown>): void {
  if (socket.readyState !== socket.OPEN) {
    return;
  }

  socket.send(JSON.stringify({ type, ...payload }));
}

function getWebSocketRoomId(request: IncomingMessage): string | null {
  const roomMatch = request.url?.match(/^\/ws\/rooms\/([^/]+)$/);
  return roomMatch?.[1] ?? null;
}

function setCorsHeaders(response: ServerResponse): void {
  response.setHeader("Access-Control-Allow-Origin", frontendUrl);
  response.setHeader("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
  response.setHeader("Access-Control-Allow-Headers", "Content-Type");
}

function sendJson(response: ServerResponse, status: number, payload: Record<string, unknown>): void {
  response.writeHead(status, {
    "Content-Type": "application/json"
  });
  response.end(JSON.stringify(payload));
}

function rawSocketMessageToString(data: RawData): string {
  if (Buffer.isBuffer(data)) {
    return data.toString("utf8");
  }

  if (data instanceof ArrayBuffer) {
    return Buffer.from(data).toString("utf8");
  }

  return Buffer.concat(data).toString("utf8");
}
