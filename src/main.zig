const std = @import("std");
const assert = @import("std").debug.assert;
const models = @import("models/models.zig");
const Cell = models.Cell;
const Grid = models.Grid;

const raylib = @import("raylib");

pub fn main() void {
    raylib.InitWindow(800, 800, "hello world!");
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.SetTargetFPS(60);

    defer raylib.CloseWindow();

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.BLACK);
        raylib.DrawFPS(10, 10);

        raylib.DrawText("hello world!", 100, 100, 20, raylib.YELLOW);
    }
}

test {
    @import("std").testing.refAllDecls(@This());
}
