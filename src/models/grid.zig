const raylib = @import("raylib");

const std = @import("std");
const Prng = std.rand.DefaultPrng;
const Cell = @import("cell.zig").Cell;
const ArrayList = std.ArrayList;

const Random = @import("../utils/random.zig").Random;
const Distance = @import("../models/distance.zig").Distance;

const Constants = @import("../core/constants.zig");
const CELL_SIZE = Constants.CELL_SIZE;

pub const Grid = struct {
    const Self = @This();

    width: usize,
    height: usize,
    cells: ArrayList(ArrayList(Cell)),

    pub const RenderOptions = struct { content_callback: ?*const fn (cell: *Cell, allocator: std.mem.Allocator) []const u8 = null, distance: ?*Distance = null };

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

    pub fn initCells(self: *Self) void {
        for (self.cells.items, 0..) |row, i| {
            for (0..(row.items.len)) |j| {
                var current: *Cell = &row.items[j];
                current.links.clearRetainingCapacity();

                if (@subWithOverflow(i, 1)[1] == 0) {
                    current.*.north = &self.cells.items[i - 1].items[j];
                }

                if (i + 1 < self.cells.items.len) {
                    current.*.south = &self.cells.items[i + 1].items[j];
                }

                if (@subWithOverflow(j, 1)[1] == 0) {
                    current.*.west = &self.cells.items[i].items[j - 1];
                }

                if (j + 1 < row.items.len) {
                    current.*.east = &self.cells.items[i].items[j + 1];
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

    pub fn getRandomCell(self: *Self) !*Cell {
        const rand_row = try Random.range(usize, 0, self.cells.items.len - 1);
        const rand_column = try Random.range(usize, 0, self.cells.items[0].items.len - 1);

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

    pub fn render(self: *const Self) void {
        for (self.cells.items) |*row| {
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

    pub fn toString(self: *Self, allocator: std.mem.Allocator, options: RenderOptions) ![]const u8 {
        var output = ArrayList(u8).init(allocator);
        var buffer: [1024]u8 = undefined;
        _ = try output.writer().write("+");

        for (0..(self.width)) |_| {
            _ = try output.writer().write("---+");
        }

        _ = try output.writer().write("\n");

        for (self.cells.items) |row| {
            var top = ArrayList(u8).init(allocator);
            var bottom = ArrayList(u8).init(allocator);

            defer top.deinit();
            defer bottom.deinit();

            _ = try top.writer().write("|");
            _ = try bottom.writer().write("+");

            for (row.items) |*cell| {
                var body: []const u8 = undefined;

                if (options.distance) |distance| {
                    if (distance.get(cell)) |d| {
                        body = try std.fmt.bufPrint(&buffer, "{d:^3}", .{d});
                    } else {
                        body = "   ";
                    }
                } else {
                    body = "   ";
                }

                var east_boundary: []const u8 = undefined;

                if (cell.east) |east| {
                    east_boundary = if (cell.isLinkedTo(east)) " " else "|";
                } else {
                    east_boundary = "|";
                }

                _ = try top.writer().write(body);
                _ = try top.writer().write(east_boundary);

                var south_boundary: []const u8 = undefined;

                if (cell.south) |south| {
                    south_boundary = if (cell.isLinkedTo(south)) "   " else "---";
                } else {
                    south_boundary = "---";
                }

                _ = try bottom.writer().write(south_boundary);
                _ = try bottom.writer().write("+");

                if (options.content_callback) |_| {
                    allocator.free(body);
                }
            }

            _ = try output.writer().write(top.items);
            _ = try output.writer().write("\n");

            _ = try output.writer().write(bottom.items);
            _ = try output.writer().write("\n");
        }

        return output.toOwnedSlice();
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

test "Grid - Get a random cell in the grid" {
    var allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var grid = try Grid.init(arena.allocator(), 3, 3);

    _ = try grid.getRandomCell();
}
