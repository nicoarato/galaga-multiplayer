import { describe, expect, it } from "vitest";

import { RoomStore } from "../../src/rooms/roomStore.js";

describe("RoomStore", () => {
  it("creates a room with deterministic metadata", () => {
    const store = createStore(["room-1"]);

    expect(store.createRoom()).toEqual({
      room: {
        id: "room-1",
        status: "lobby",
        hostPlayerId: null,
        players: [],
        createdAt: "2026-08-02T00:00:00.000Z"
      }
    });
  });

  it("gets null for missing rooms", () => {
    const store = createStore([]);

    expect(store.getRoom("missing")).toBeNull();
  });

  it("joins players and assigns the first player as host", () => {
    const store = createStore(["room-1", "player-1", "player-2"]);
    store.createRoom();

    const hostResult = store.joinRoom("room-1", "Nico");
    const guestResult = store.joinRoom("room-1", "Guest");

    expect(hostResult).toMatchObject({
      ok: true,
      player: {
        id: "player-1",
        name: "Nico",
        ready: false,
        connected: true
      },
      room: {
        hostPlayerId: "player-1"
      }
    });
    expect(guestResult).toMatchObject({
      ok: true,
      player: {
        id: "player-2",
        name: "Guest",
        ready: false,
        connected: true
      },
      room: {
        hostPlayerId: "player-1"
      }
    });
  });

  it("does not expose mutable room state", () => {
    const store = createStore(["room-1", "player-1"]);
    store.createRoom();
    store.joinRoom("room-1", "Nico");

    const room = store.getRoom("room-1");
    expect(room).not.toBeNull();

    room?.players.push({
      id: "external",
      name: "External",
      ready: true,
      connected: true
    });

    expect(store.getRoom("room-1")?.players).toHaveLength(1);
  });

  it("rejects joins for missing, full, or already started rooms", () => {
    const store = createStore(["room-1", "player-1"], 1);

    expect(store.joinRoom("missing", "Nico")).toEqual({
      ok: false,
      reason: "room_not_found"
    });

    store.createRoom();
    store.joinRoom("room-1", "Nico");

    expect(store.joinRoom("room-1", "Extra")).toEqual({
      ok: false,
      reason: "room_full"
    });

    expect(store.startGame("room-1", "player-1")).toMatchObject({ ok: true });

    expect(store.joinRoom("room-1", "Late")).toEqual({
      ok: false,
      reason: "game_already_started"
    });
  });

  it("removes players, reassigns host, and deletes empty rooms", () => {
    const store = createStore(["room-1", "host", "guest"]);
    store.createRoom();
    store.joinRoom("room-1", "Host");
    store.joinRoom("room-1", "Guest");

    expect(store.leaveRoom("room-1", "host")).toEqual({
      ok: true,
      roomDeleted: false,
      room: {
        id: "room-1",
        status: "lobby",
        hostPlayerId: "guest",
        players: [
          {
            id: "guest",
            name: "Guest",
            ready: false,
            connected: true
          }
        ],
        createdAt: "2026-08-02T00:00:00.000Z"
      }
    });

    expect(store.leaveRoom("room-1", "guest")).toEqual({
      ok: true,
      roomDeleted: true,
      room: null
    });
    expect(store.getRoom("room-1")).toBeNull();
  });

  it("rejects leave for missing rooms or players", () => {
    const store = createStore(["room-1"]);

    expect(store.leaveRoom("missing", "player")).toEqual({
      ok: false,
      reason: "room_not_found"
    });

    store.createRoom();

    expect(store.leaveRoom("room-1", "missing")).toEqual({
      ok: false,
      reason: "player_not_found"
    });
  });

  it("updates ready state", () => {
    const store = createStore(["room-1", "player-1"]);
    store.createRoom();
    store.joinRoom("room-1", "Nico");

    expect(store.setReady("room-1", "player-1", true)).toMatchObject({
      ok: true,
      player: {
        id: "player-1",
        ready: true
      },
      room: {
        players: [
          {
            id: "player-1",
            ready: true
          }
        ]
      }
    });
  });

  it("rejects ready updates for missing rooms or players", () => {
    const store = createStore(["room-1"]);

    expect(store.setReady("missing", "player", true)).toEqual({
      ok: false,
      reason: "room_not_found"
    });

    store.createRoom();

    expect(store.setReady("room-1", "missing", true)).toEqual({
      ok: false,
      reason: "player_not_found"
    });
  });

  it("starts a game when host starts and guests are ready", () => {
    const store = createStore(["room-1", "host", "guest"]);
    store.createRoom();
    store.joinRoom("room-1", "Host");
    store.joinRoom("room-1", "Guest");
    store.setReady("room-1", "guest", true);

    expect(store.startGame("room-1", "host")).toMatchObject({
      ok: true,
      room: {
        status: "in_game"
      }
    });
  });

  it("rejects invalid start_game attempts", () => {
    const store = createStore(["room-1", "host", "guest"]);

    expect(store.startGame("missing", "host")).toEqual({
      ok: false,
      reason: "room_not_found"
    });

    store.createRoom();

    expect(store.startGame("room-1", "missing")).toEqual({
      ok: false,
      reason: "player_not_found"
    });

    store.joinRoom("room-1", "Host");
    store.joinRoom("room-1", "Guest");

    expect(store.startGame("room-1", "guest")).toEqual({
      ok: false,
      reason: "not_host"
    });

    expect(store.startGame("room-1", "host")).toEqual({
      ok: false,
      reason: "players_not_ready"
    });

    store.setReady("room-1", "guest", true);
    expect(store.startGame("room-1", "host")).toMatchObject({ ok: true });

    expect(store.startGame("room-1", "host")).toEqual({
      ok: false,
      reason: "already_started"
    });
  });

  it("stores player positions only after game start", () => {
    const store = createStore(["room-1", "host", "guest"]);
    store.createRoom();
    store.joinRoom("room-1", "Host");
    store.joinRoom("room-1", "Guest");

    expect(store.setPlayerPosition("room-1", "host", { x: 10, y: 20 })).toEqual({
      ok: false,
      reason: "game_not_started"
    });

    store.setReady("room-1", "guest", true);
    store.startGame("room-1", "host");

    expect(store.setPlayerPosition("room-1", "host", { x: 10, y: 20 })).toEqual({
      ok: true,
      player: {
        id: "host",
        name: "Host",
        ready: false,
        connected: true,
        position: {
          x: 10,
          y: 20
        }
      },
      room: {
        id: "room-1",
        status: "in_game",
        hostPlayerId: "host",
        players: [
          {
            id: "host",
            name: "Host",
            ready: false,
            connected: true,
            position: {
              x: 10,
              y: 20
            }
          },
          {
            id: "guest",
            name: "Guest",
            ready: true,
            connected: true
          }
        ],
        createdAt: "2026-08-02T00:00:00.000Z"
      }
    });
  });

  it("rejects position updates for missing rooms or players", () => {
    const store = createStore(["room-1", "host"]);

    expect(store.setPlayerPosition("missing", "host", { x: 0, y: 0 })).toEqual({
      ok: false,
      reason: "room_not_found"
    });

    store.createRoom();
    store.joinRoom("room-1", "Host");
    store.startGame("room-1", "host");

    expect(store.setPlayerPosition("room-1", "missing", { x: 0, y: 0 })).toEqual({
      ok: false,
      reason: "player_not_found"
    });
  });

  it("retries generated room ids when an id already exists", () => {
    const store = createStore(["same-id", "same-id", "room-2"]);

    expect(store.createRoom().room.id).toBe("same-id");
    expect(store.createRoom().room.id).toBe("room-2");
  });
});

function createStore(ids: string[], maxPlayers = 2): RoomStore {
  let index = 0;

  return new RoomStore({
    maxPlayers,
    createId: () => {
      if (index >= ids.length) {
        throw new Error("Test id sequence exhausted");
      }

      const id = ids[index];
      index += 1;

      return id;
    },
    now: () => new Date("2026-08-02T00:00:00.000Z")
  });
}
