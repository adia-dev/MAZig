const std = @import("std");
const raylib = @import("raylib");

const models = @import("models/models.zig");
const generators = @import("generators/generators.zig");

const Cell = models.Cell;
const Grid = models.Grid;

const BinaryTree = generators.BinaryTree;
const Sidewinder = generators.SideWinder;

const Constants = @import("core/constants.zig");
const CELL_SIZE = Constants.CELL_SIZE;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var grid = try Grid.init(arena.allocator(), 25, 25);
    try BinaryTree.generate(&grid);

    const grid_width: i32 = @intCast(grid.width);
    const grid_height: i32 = @intCast(grid.height);

    raylib.InitWindow(grid_width * CELL_SIZE, grid_height * CELL_SIZE, "hello world!");
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.SetTargetFPS(60);

    defer raylib.CloseWindow();

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        if (raylib.IsKeyPressed(.KEY_SPACE)) {
            grid.initCells();
            try BinaryTree.generate(&grid);
        }

        if (raylib.IsKeyPressed(.KEY_LEFT_SHIFT)) {
            grid.initCells();
            try Sidewinder.generate(&grid);
        }

        raylib.ClearBackground(raylib.WHITE);
        grid.render();
        raylib.DrawFPS(10, 10);
    }
}

test {
    @import("std").testing.refAllDecls(@This());
}
