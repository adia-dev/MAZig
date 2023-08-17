const std = @import("std");
const assert = @import("std").debug.assert;

const models = @import("models/models.zig");
const generators = @import("generators/generators.zig");

const Cell = models.Cell;
const Grid = models.Grid;

const BinaryTree = generators.BinaryTree;
const Sidewinder = generators.SideWinder;

const raylib = @import("raylib");

const CELL_SIZE: i32 = 32;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var grid = try Grid.init(arena.allocator(), 25, 25);
    try BinaryTree.generate(&grid);

    defer arena.deinit();

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
        raylib.DrawFPS(10, 10);

        for (grid.cells.items) |*row| {
            for (row.items) |*cell| {
                const x1: i32 = @intCast(cell.column * CELL_SIZE);
                const y1: i32 = @intCast(cell.row * CELL_SIZE);

                const x2: i32 = @intCast((cell.column + 1) * CELL_SIZE);
                const y2: i32 = @intCast((cell.row + 1) * CELL_SIZE);

                if (cell.north == null) {
                    raylib.DrawLine(x1, y1, x2, y1, raylib.BLACK);
                }

                if (cell.west == null) {
                    raylib.DrawLine(x1, y1, x1, y2, raylib.BLACK);
                }

                if (cell.east) |east| {
                    if (!cell.isLinkedTo(east)) {
                        raylib.DrawLine(x2, y1, x2, y2, raylib.BLACK);
                    }
                } else {
                    raylib.DrawLine(x2, y1, x2, y2, raylib.BLACK);
                }

                if (cell.south) |south| {
                    if (!cell.isLinkedTo(south)) {
                        raylib.DrawLine(x1, y2, x2, y2, raylib.BLACK);
                    }
                } else {
                    raylib.DrawLine(x1, y2, x2, y2, raylib.BLACK);
                }
            }
        }
    }
}

test {
    @import("std").testing.refAllDecls(@This());
}
