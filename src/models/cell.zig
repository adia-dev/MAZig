const std = @import("std");
const ArrayList = std.ArrayList;
const AutoHashmap = std.AutoHashMap;

pub const Cell = struct {
    const Self = @This();

    row: usize,
    column: usize,

    north: ?*Self = null,
    south: ?*Self = null,
    east: ?*Self = null,
    west: ?*Self = null,

    links: AutoHashmap(*Self, void),
    allocator: std.mem.Allocator,
    memory: []u8,

    pub fn init(allocator: std.mem.Allocator, row: usize, column: usize) !Self {
        return Self{ .row = row, .column = column, .allocator = allocator, .memory = try allocator.alloc(u8, 100), .links = AutoHashmap(*Self, void).init(allocator) };
    }

    pub fn linkTo(self: *Self, cell: *Cell) !void {
        try self.*.links.put(cell, {});
    }

    pub fn unlink(self: *Self, cell: *Cell) bool {
        return self.*.links.remove(cell);
    }

    pub fn deinit(self: *Self) void {
        self.links.deinit();
        self.allocator.free(self.memory);
    }
};

test "Cell - Init" {
    var allocator = std.testing.allocator;
    var cell = try Cell.init(allocator, 10, 10);
    defer cell.deinit();

    try std.testing.expect(cell.row == 10);
    try std.testing.expect(cell.column == 10);

    try std.testing.expect(cell.north == null);
    try std.testing.expect(cell.south == null);
    try std.testing.expect(cell.east == null);
    try std.testing.expect(cell.west == null);

    try std.testing.expect(cell.allocator.ptr == allocator.ptr);
    try std.testing.expect(cell.memory.len == 100);
    try std.testing.expect(cell.links.count() == 0);
}

test "Cell - Link to another Cell" {
    var allocator = std.testing.allocator;
    var cell = try Cell.init(allocator, 10, 10);
    defer cell.deinit();

    var other_cell = try Cell.init(allocator, 20, 20);
    defer other_cell.deinit();

    try cell.linkTo(&other_cell);

    try std.testing.expect(cell.links.count() == 1);
}

test "Cell - Unlink to another Cell" {
    var allocator = std.testing.allocator;
    var cell = try Cell.init(allocator, 10, 10);
    defer cell.deinit();

    var other_cell = try Cell.init(allocator, 20, 20);
    defer other_cell.deinit();

    try cell.linkTo(&other_cell);
    try std.testing.expect(cell.links.count() == 1);

    _ = cell.unlink(&other_cell);
    try std.testing.expect(cell.links.count() == 0);
}

test "Cell - Add neighbors to Cell" {
    var allocator = std.testing.allocator;
    var cell = try Cell.init(allocator, 10, 10);
    defer cell.deinit();

    var other_cell = try Cell.init(allocator, 20, 20);
    defer other_cell.deinit();

    cell.north = &other_cell;
    try std.testing.expect(cell.north == &other_cell);
}
