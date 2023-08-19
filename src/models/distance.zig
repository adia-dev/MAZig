const std = @import("std");
const AutoHashmap = std.AutoHashMap;

const Cell = @import("../models/cell.zig").Cell;
const Grid = @import("../models/grid.zig").Grid;

const BinaryTree = @import("../generators/binary_tree.zig").BinaryTree;
const Sidewinder = @import("../generators/binary_tree.zig").Sidewinder;

pub const Distance = struct {
    const Self = @This();

    root: *const Cell,
    map: AutoHashmap(*const Cell, usize),

    pub fn init(allocator: std.mem.Allocator, root: *const Cell) !Self {
        var distance = Self{ .root = root, .map = AutoHashmap(*const Cell, usize).init(allocator) };
        try distance.set(root, 0);
        return distance;
    }

    pub fn get(self: *Self, cell: *const Cell) ?usize {
        return self.map.get(cell);
    }

    pub fn set(self: *Self, cell: *const Cell, distance: usize) !void {
        return try self.map.put(cell, distance);
    }

    pub fn has(self: *Self, cell: *const Cell) bool {
        return self.map.contains(cell);
    }

    pub fn deinit(self: *Self) void {
        self.map.deinit();
    }

    pub fn cell_content(self: *Self, cell: *Cell, allocator: std.mem.Allocator) []const u8 {
        _ = allocator;
        _ = cell;
        _ = self;
        return "   ";
    }
};

test "Distance - Init" {
    var allocator = std.testing.allocator;
    var cell = try Cell.init(allocator, 10, 10);
    defer cell.deinit();

    var distance = try Distance.init(allocator, &cell);
    defer distance.deinit();

    try std.testing.expectEqual(distance.get(&cell), 0);
}

test "Distance - Set" {
    var allocator = std.testing.allocator;
    var cell = try Cell.init(allocator, 10, 10);
    defer cell.deinit();

    var other_cell = try Cell.init(allocator, 10, 10);
    defer other_cell.deinit();

    var distance = try Distance.init(allocator, &cell);
    defer distance.deinit();

    try distance.set(&other_cell, 10);

    try std.testing.expectEqual(distance.get(&cell), 0);
    try std.testing.expectEqual(distance.get(&other_cell), 10);
}

test "Distance - Cell content" {
    var allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var grid = try Grid.init(arena.allocator(), 25, 25);
    try BinaryTree.generate(&grid);

    var random_cell = try grid.getRandomCell();
    var distance = try random_cell.distance(arena.allocator());

    const binary_tree_maze = try grid.toString(arena.allocator(), .{ .distance = &distance });

    std.debug.print("\nBinary Tree Maze(Distance content modifier):\n{s}\n", .{binary_tree_maze});

    grid.initCells();
    try BinaryTree.generate(&grid);

    distance.deinit();

    random_cell = try grid.getRandomCell();
    distance = try random_cell.distance(arena.allocator());

    const sidewinder_maze = try grid.toString(arena.allocator(), .{ .distance = &distance });
    std.debug.print("\nSidewinder Maze(Distance content modifier):\n{s}\n", .{sidewinder_maze});
}
