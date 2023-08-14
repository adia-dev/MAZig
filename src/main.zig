const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_ttf.h");
});

const std = @import("std");
const assert = @import("std").debug.assert;
const models = @import("models/models.zig");
const Cell = models.Cell;

pub fn lerp(a: f32, b: f32, t: f32) f32 {
    return a + (b - a) * t;
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    var cell = try Cell.init(allocator, 10, 10);
    var other_cell = try Cell.init(allocator, 20, 20);
    try cell.linkTo(&other_cell);

    defer other_cell.deinit();
    defer cell.deinit();

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    if (c.TTF_Init() != 0) {
        c.SDL_Log("Unable to initialize SDL_ttf: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.TTF_Quit();

    const screen = c.SDL_CreateWindow("Mazes", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 720, 480, c.SDL_WINDOW_OPENGL | c.SDL_RENDERER_PRESENTVSYNC) orelse {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    var quit = false;
    var is_running = false;
    // var last_time = c.SDL_GetTicks();

    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                c.SDL_KEYDOWN => {
                    const key_code = event.key.keysym.sym;
                    switch (key_code) {
                        c.SDLK_ESCAPE => {
                            quit = true;
                        },
                        c.SDLK_LSHIFT => {
                            is_running = true;
                        },
                        else => {
                            std.debug.print("Key: {} PRESSED.\n", .{key_code});
                        },
                    }
                },
                c.SDL_KEYUP => {
                    const key_code = event.key.keysym.sym;
                    if (key_code == c.SDLK_LSHIFT) {
                        is_running = false;
                    }
                },
                else => {},
            }
        }

        // const current_time = c.SDL_GetTicks();
        // const delta_time = current_time - last_time;
        // last_time = current_time;
        // const dt_seconds = @as(f32, @floatFromInt(delta_time)) / 1000.0;

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);

        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(17);
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit();
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test {
    @import("std").testing.refAllDecls(@This());
}
