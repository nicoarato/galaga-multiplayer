import { describe, expect, it } from "vitest";

import { parseClientMessage } from "../../src/protocol/messages.js";

describe("parseClientMessage", () => {
  it("parses join_room and trims playerName", () => {
    expect(parseClientMessage(JSON.stringify({ type: "join_room", playerName: " Nico " }))).toEqual({
      ok: true,
      message: {
        type: "join_room",
        playerName: "Nico"
      }
    });
  });

  it("rejects invalid JSON", () => {
    expect(parseClientMessage("{")).toEqual({
      ok: false,
      error: {
        message: "Message must be valid JSON"
      }
    });
  });

  it("rejects non-object messages", () => {
    expect(parseClientMessage("[]")).toEqual({
      ok: false,
      error: {
        message: "Message must be an object"
      }
    });
  });

  it("requires a message type", () => {
    expect(parseClientMessage(JSON.stringify({}))).toEqual({
      ok: false,
      error: {
        message: "Message type is required"
      }
    });
  });

  it("rejects unsupported message types", () => {
    expect(parseClientMessage(JSON.stringify({ type: "unknown" }))).toEqual({
      ok: false,
      error: {
        message: "Unsupported message type: unknown"
      }
    });
  });

  it("validates join_room playerName", () => {
    expect(parseClientMessage(JSON.stringify({ type: "join_room" }))).toEqual({
      ok: false,
      error: {
        message: "playerName is required"
      }
    });

    expect(parseClientMessage(JSON.stringify({ type: "join_room", playerName: "   " }))).toEqual({
      ok: false,
      error: {
        message: "playerName cannot be empty"
      }
    });

    expect(parseClientMessage(JSON.stringify({ type: "join_room", playerName: "a".repeat(25) }))).toEqual({
      ok: false,
      error: {
        message: "playerName cannot exceed 24 characters"
      }
    });
  });

  it("parses leave_room", () => {
    expect(parseClientMessage(JSON.stringify({ type: "leave_room" }))).toEqual({
      ok: true,
      message: {
        type: "leave_room"
      }
    });
  });

  it("parses set_ready", () => {
    expect(parseClientMessage(JSON.stringify({ type: "set_ready", ready: true }))).toEqual({
      ok: true,
      message: {
        type: "set_ready",
        ready: true
      }
    });
  });

  it("validates set_ready ready", () => {
    expect(parseClientMessage(JSON.stringify({ type: "set_ready", ready: "yes" }))).toEqual({
      ok: false,
      error: {
        message: "ready must be a boolean"
      }
    });
  });

  it("parses start_game", () => {
    expect(parseClientMessage(JSON.stringify({ type: "start_game" }))).toEqual({
      ok: true,
      message: {
        type: "start_game"
      }
    });
  });

  it("parses ping", () => {
    expect(parseClientMessage(JSON.stringify({ type: "ping", timestamp: 123 }))).toEqual({
      ok: true,
      message: {
        type: "ping",
        timestamp: 123
      }
    });
  });

  it("parses player_position", () => {
    expect(parseClientMessage(JSON.stringify({ type: "player_position", position: { x: 120, y: 240 } }))).toEqual({
      ok: true,
      message: {
        type: "player_position",
        position: {
          x: 120,
          y: 240
        }
      }
    });
  });

  it("validates player_position", () => {
    expect(parseClientMessage(JSON.stringify({ type: "player_position" }))).toEqual({
      ok: false,
      error: {
        message: "position is required"
      }
    });

    expect(parseClientMessage(JSON.stringify({ type: "player_position", position: { x: "0", y: 10 } }))).toEqual({
      ok: false,
      error: {
        message: "position.x must be a finite number"
      }
    });

    expect(parseClientMessage(JSON.stringify({ type: "player_position", position: { x: 0, y: Number.NaN } }))).toEqual({
      ok: false,
      error: {
        message: "position.y must be a finite number"
      }
    });
  });

  it("parses player_shot", () => {
    expect(parseClientMessage(JSON.stringify({ type: "player_shot", shot: { x: 120, y: 240 } }))).toEqual({
      ok: true,
      message: {
        type: "player_shot",
        shot: {
          x: 120,
          y: 240
        }
      }
    });
  });

  it("validates player_shot", () => {
    expect(parseClientMessage(JSON.stringify({ type: "player_shot" }))).toEqual({
      ok: false,
      error: {
        message: "shot is required"
      }
    });

    expect(parseClientMessage(JSON.stringify({ type: "player_shot", shot: { x: "0", y: 10 } }))).toEqual({
      ok: false,
      error: {
        message: "shot.x must be a finite number"
      }
    });

    expect(parseClientMessage(JSON.stringify({ type: "player_shot", shot: { x: 0, y: Number.NaN } }))).toEqual({
      ok: false,
      error: {
        message: "shot.y must be a finite number"
      }
    });
  });

  it("validates ping timestamp", () => {
    expect(parseClientMessage(JSON.stringify({ type: "ping", timestamp: Number.NaN }))).toEqual({
      ok: false,
      error: {
        message: "timestamp must be a finite number"
      }
    });
  });
});
