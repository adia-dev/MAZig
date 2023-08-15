const std = @import("std");
const AutoHashmap = std.AutoHashMap;

/// TODO: document this class and methods
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
        try cell.*.links.put(self, {});
    }

    pub fn unlink(self: *Self, cell: *Cell) bool {
        return self.*.links.remove(cell) and cell.*.links.remove(self);
    }

    pub fn deinit(self: *Self) void {
        self.links.deinit();
        self.allocator.free(self.memory);
    }

    pub fn isLinkedTo(self: *const Self, cell: *Cell) bool {
        return self.links.contains(cell);
    }

    pub fn print(self: *const Self) void {
        std.debug.print(
            \\ Cell({*}):
            \\      coords:
            \\          row: {d}
            \\          column: {d}
            \\      neighbors:
            \\          north: {?*}
            \\          south: {?*}
            \\          east: {?*} 
            \\          west: {?*} 
            \\      links:
            \\          count: {d}
            \\      memory:
            \\          size: {d} bytes
            \\
        , .{ self, self.row, self.column, self.north, self.south, self.east, self.west, self.links.count(), self.memory.len });
    }

    pub fn toString(self: *const Self, allocator: std.mem.Allocator) []const u8 {
        return std.fmt.allocPrint(allocator,
            \\ Cell({*}):
            \\      coords:
            \\          row: {d}
            \\          column: {d}
            \\      neighbors:
            \\          north: {?*}
            \\          south: {?*}
            \\          east: {?*} 
            \\          west: {?*} 
            \\      links:
            \\          count: {d}
            \\      memory:
            \\          size: {d} bytes
            \\
        , .{ self, self.row, self.column, self.north, self.south, self.east, self.west, self.links.count(), self.memory.len }) catch
            "(null)";
    }
};

test "Cell - Init" {
    var allocator = std.testing.allocator;
    var cell = try Cell.init(allocator, 10, 10);
    defer cell.deinit();

    try std.testing.expectEqual(cell.row, 10);
    try std.testing.expectEqual(cell.column, 10);

    try std.testing.expectEqual(cell.north, null);
    try std.testing.expectEqual(cell.south, null);
    try std.testing.expectEqual(cell.east, null);
    try std.testing.expectEqual(cell.west, null);

    try std.testing.expectEqual(cell.allocator.ptr, allocator.ptr);
    try std.testing.expectEqual(cell.memory.len, 100);
    try std.testing.expectEqual(cell.links.count(), 0);
}

test "Cell - Link to another Cell" {
    var allocator = std.testing.allocator;
    var cell = try Cell.init(allocator, 10, 10);
    defer cell.deinit();

    var other_cell = try Cell.init(allocator, 20, 20);
    defer other_cell.deinit();

    try cell.linkTo(&other_cell);

    try std.testing.expectEqual(cell.links.count(), 1);
    try std.testing.expectEqual(other_cell.links.count(), 1);
}

test "Cell - Unlink to another Cell" {
    var allocator = std.testing.allocator;
    var cell = try Cell.init(allocator, 10, 10);
    defer cell.deinit();

    var other_cell = try Cell.init(allocator, 20, 20);
    defer other_cell.deinit();

    try cell.linkTo(&other_cell);
    try std.testing.expectEqual(cell.links.count(), 1);
    try std.testing.expectEqual(other_cell.links.count(), 1);

    _ = cell.unlink(&other_cell);
    try std.testing.expectEqual(cell.links.count(), 0);
    try std.testing.expectEqual(other_cell.links.count(), 0);
}

test "Cell - Add neighbors to Cell" {
    var allocator = std.testing.allocator;
    var cell = try Cell.init(allocator, 10, 10);
    defer cell.deinit();

    var other_cell = try Cell.init(allocator, 20, 20);
    defer other_cell.deinit();

    cell.north = &other_cell;
    try std.testing.expectEqual(cell.north, &other_cell);
}

test "Cell - Iterate over the links of a Cell" {
    var allocator = std.testing.allocator;
    var cell = try Cell.init(allocator, 10, 10);
    defer cell.deinit();

    var other_cell = try Cell.init(allocator, 20, 20);
    defer other_cell.deinit();

    var yet_another_cell = try Cell.init(allocator, 20, 20);
    defer yet_another_cell.deinit();

    try cell.linkTo(&other_cell);
    try cell.linkTo(&yet_another_cell);

    try std.testing.expectEqual(cell.links.count(), 2);

    var it = cell.links.keyIterator();
    while (it.next()) |k| {
        try std.testing.expectEqual(k.*.links.count(), 1);
    }
}

test "Cell - Check if a Cell is linked to another one" {
    var allocator = std.testing.allocator;
    var cell = try Cell.init(allocator, 10, 10);
    defer cell.deinit();

    var other_cell = try Cell.init(allocator, 20, 20);
    defer other_cell.deinit();

    try cell.linkTo(&other_cell);
    try std.testing.expectEqual(cell.links.count(), 1);

    try std.testing.expect(cell.isLinkedTo(&other_cell));
    try std.testing.expect(other_cell.isLinkedTo(&cell));
}
