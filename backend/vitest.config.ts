import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    coverage: {
      provider: "v8",
      reporter: ["text", "lcov"],
      thresholds: {
        branches: 100,
        functions: 100,
        lines: 100,
        statements: 100
      },
      include: ["src/protocol/**/*.ts", "src/rooms/roomStore.ts"],
      exclude: ["src/server.ts", "src/ids.ts", "src/rooms/room.ts"]
    }
  }
});
