const std = @import("std");
const Random = @import("../utils/random.zig").Random;
const models = @import("../models/models.zig");
const Cell = models.Cell;
const Grid = models.Grid;

const Sidewinder = struct {
    const Self = @This();

    pub fn generate(grid: *Grid) !void {
        var allocator = std.heap.page_allocator;

        var previous = std.ArrayList(*Cell).init(allocator);
        defer previous.deinit();

        for (grid.cells.items) |*row| {
            for (row.items) |*cell| {
                try previous.append(cell);

                const should_go_north = cell.east == null or (cell.north != null and try Random.flipCoin() == 1);
                if (should_go_north) {
                    var random_cell_index: usize = try Random.range(usize, 0, previous.items.len - 1);
                    var random_cell: *Cell = previous.items[random_cell_index];

                    if (random_cell.north) |north| {
                        try random_cell.linkTo(north);
                    }

                    previous.clearRetainingCapacity();
                } else {
                    if (cell.east) |east| {
                        try cell.linkTo(east);
                    }
                }
            }
        }
    }
};

test "Generator - Sidewinder - generate" {
    var allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var grid = try Grid.init(arena.allocator(), 4, 4);

    try Sidewinder.generate(&grid);

    const grid_str = try grid.toString(arena.allocator());

    std.debug.print("\nSidewinder Maze:\n{s}\n", .{grid_str});
}
