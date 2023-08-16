const time = @cImport(@cInclude("time.h"));
const cstd = @cImport(@cInclude("stdlib.h"));
const std = @import("std");

pub const Random = struct {
    pub fn flipCoin() u8 {
        const rnd: u8 = @intCast(@rem(cstd.rand(), 2));
        return rnd;
    }

    pub fn range(comptime T: type, min: T, max: T) !T {
        var prng = std.rand.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try std.os.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });
        const rand = prng.random();

        return rand.intRangeAtMost(T, min, max);
    }
};

test "Utils - Random - flipCoin(cStyle)" {
    for (0..100) |i| {
        _ = i;
        const r = Random.flipCoin();
        try std.testing.expect(r == 0 or r == 1);
    }
}

test "Utils - Random - flipCoin" {
    for (0..100) |i| {
        _ = i;
        const r = try Random.range(u8, 0, 1);
        try std.testing.expect(r == 0 or r == 1);
    }
}

test "Utils - Random - Builtin DefaultPrng" {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    const a = rand.float(f32);
    const b = rand.boolean();
    const c = rand.int(u8);
    const d = rand.intRangeAtMost(u8, 0, 255);

    _ = .{ a, b, c, d };
}

test "Utils - Random - range" {
    const random_number: u8 = try Random.range(u8, 0, 255);

    try std.testing.expect(random_number >= 0 and random_number <= 255);
}
