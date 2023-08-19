const std = @import("std");

const models = @import("../models/models.zig");
const Random = @import("../utils/random.zig").Random;

const Cell = models.Cell;
const Grid = models.Grid;

pub const BinaryTree = struct {
    const Self = @This();

    pub fn generate(grid: *Grid) !void {
        for (grid.cells.items) |*row| {
            for (row.items) |*cell| {
                if (try Random.flipCoin() == 0) {
                    if (cell.north) |north| {
                        try cell.linkTo(north);
                    }
                } else {
                    if (cell.east) |east| {
                        try cell.linkTo(east);
                    } else if (cell.north) |north| {
                        try cell.linkTo(north);
                    }
                }
            }
        }
    }
};

test "Generator - BinaryTree - generate" {
    var allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var grid = try Grid.init(arena.allocator(), 25, 25);

    try BinaryTree.generate(&grid);

    const grid_str = try grid.toString(arena.allocator(), .{});

    std.debug.print("\nBinary Tree Maze:\n{s}\n", .{grid_str});
}
