pub const BinaryTree = @import("binary_tree.zig").BinaryTree;
pub const SideWinder = @import("sidewinder.zig").Sidewinder;
const Grid = @import("../models/grid.zig").Grid;

pub const Generator = union(enum) {
    const Self = @This();
    binary_tree: BinaryTree,
    sidewinder: SideWinder,

    pub fn generate(self: Self, grid: *Grid) void {
        switch (self) {
            inline else => |case| case.generate(grid),
        }
    }
};
