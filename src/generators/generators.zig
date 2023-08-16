pub const BinaryTree = @import("binary_tree.zig").BinaryTree;
const Grid = @import("../models/grid.zig").Grid;

const Generator = union(enum) {
    const Self = @This();
    binary_tree: BinaryTree,

    pub fn generate(self: Self, grid: *Grid) void {
        switch (self) {
            inline else => |case| case.generate(grid),
        }
    }
};
