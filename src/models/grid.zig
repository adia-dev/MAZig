const std = @import("std");
const Prng = std.rand.DefaultPrng;
const Cell = @import("cell.zig").Cell;
const ArrayList = std.ArrayList;

pub const Grid = struct {
    const Self = @This();

    width: usize,
    height: usize,
    cells: ArrayList(ArrayList(Cell)),

    pub fn init(allocator: std.mem.Allocator, width: usize, height: usize) !Self {
        var new_grid = Self{ .width = width, .height = height, .cells = undefined };

        try new_grid.initGrid(allocator);
        new_grid.initCells();

        return new_grid;
    }

    fn initGrid(self: *Self, allocator: std.mem.Allocator) !void {
        self.cells = ArrayList(ArrayList(Cell)).init(allocator);
        for (0..(self.height)) |i| {
            var list = ArrayList(Cell).init(allocator);
            for (0..(self.width)) |j| {
                try list.append(try Cell.init(allocator, i, j));
            }
            try self.cells.append(list);
        }
    }

    fn initCells(self: *Self) void {
        for (self.cells.items, 0..) |row, i| {
            for (0..(row.items.len)) |j| {
                var current: *Cell = &row.items[j];

                if (@subWithOverflow(i, 1)[1] == 0) {
                    current.*.north = &self.cells.items[i - 1].items[j];
                }

                if (i + 1 < self.cells.items.len) {
                    current.*.south = &self.cells.items[i + 1].items[j];
                }

                if (@subWithOverflow(j, 1)[1] == 0) {
                    current.*.east = &self.cells.items[i].items[j - 1];
                }

                if (j + 1 < row.items.len) {
                    current.*.west = &self.cells.items[i].items[j + 1];
                }
            }
        }
    }

    pub fn size(self: *Self) usize {
        return self.cells.items.len * self.cells.items[0].items.len;
    }

    pub fn get(self: *Self, row: usize, column: usize) ?*Cell {
        if (row >= self.cells.items.len or column >= self.cells.items[0].items.len) return null;

        return &self.cells.items[row].items[column];
    }

    pub fn getRandomCell(self: *Self) *Cell {
        var prng = Prng.init(blk: {
            var seed: u8 = undefined;
            try std.os.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });

        const rand = prng.random();

        const rand_row = rand.intRangeAtMost(usize, 0, self.cells.items.len);
        const rand_column = rand.intRangeAtMost(usize, 0, self.cells.items[0].len);

        return &self.cells.items[rand_row].items[rand_column];
    }

    pub fn forEach(self: *Self, callback: *const fn (cell: *Cell) void) void {
        for (self.cells.items, 0..) |row, i| {
            _ = i;
            for (row.items, 0..) |*cell, j| {
                _ = j;
                callback(cell);
            }
        }
    }
};

test "Grid - Init" {
    var allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var grid = try Grid.init(arena.allocator(), 3, 3);

    try std.testing.expectEqual(grid.width, 3);
    try std.testing.expectEqual(grid.height, 3);
}

test "Grid - Get a cell from the grid" {
    var allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var grid = try Grid.init(arena.allocator(), 3, 3);

    const target: *Cell = &grid.cells.items[0].items[0];

    try std.testing.expectEqual(target, grid.get(0, 0).?);
}

test "Grid - Size of the grid" {
    var allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var grid = try Grid.init(arena.allocator(), 3, 3);

    try std.testing.expectEqual(grid.size(), 9);
}

pub fn _onlyForTest(cell: *Cell) void {
    _ = cell;
}
test "Grid - ForEach cells in the grid do..." {
    var allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var grid = try Grid.init(arena.allocator(), 3, 3);

    grid.forEach(_onlyForTest);
}
