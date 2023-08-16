const time = @cImport(@cInclude("time.h"));
const cstd = @cImport(@cInclude("stdlib.h"));
const std = @import("std");
const Prng = std.rand.DefaultPrng;

const models = @import("../models/models.zig");
const Cell = models.Cell;
const Grid = models.Grid;

const BinaryTree = struct {
    const Self = @This();

    pub fn generate(grid: *Grid) !void {
        for (grid.cells.items) |*row| {
            for (row.items) |*cell| {
                if (BinaryTree.flipCoin() == 0) {
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

    pub fn flipCoin() u8 {
        const rnd: u8 = @intCast(@rem(cstd.rand(), 2));
        return rnd;
    }
};

test "Generator - BinaryTree - flipCoin" {
    const t: u32 = @intCast(time.time(0));
    cstd.srand(t);

    for (0..100) |i| {
        _ = i;
        const r = BinaryTree.flipCoin();
        try std.testing.expect(r == 0 or r == 1);
    }
}

test "Generator - BinaryTree - generate" {
    var allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var grid = try Grid.init(arena.allocator(), 25, 25);

    try BinaryTree.generate(&grid);

    const grid_str = try grid.toString(arena.allocator());

    std.debug.print("\nBinary Tree Maze:\n{s}\n", .{grid_str});
}
