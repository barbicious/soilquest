const std = @import("std");
const Renderer = @import("gfx/Renderer.zig");
const Texture = @import("gfx/Texture.zig");
const Tile = @import("lvl/Tile.zig");
const color = @import("gfx/color.zig");

const c = @import("c");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.arena.allocator();

    _ = std.debug.lockStderr(&.{});
    std.debug.unlockStderr();

    try Texture.Registry.init(io, allocator);
    defer Texture.registry.deinit(allocator);

    try Tile.Registry.init(io, allocator);
    defer Tile.registry.deinit(allocator);

    const grass_tile = Tile.registry.tiles.items[0];

    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        return error.FailedToInitSDL;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Soilquest", 1280, 720, 0) orelse return error.FailedToCreateWindow;
    defer c.SDL_DestroyWindow(window);

    var running = true;

    var event: c.SDL_Event = undefined;

    var renderer: Renderer = try .init(window);
    defer renderer.deinit();

    while (running) {
        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) {
                running = false;
            }
        }

        renderer.flush();

        grass_tile.blit(&renderer, 0, 0);

        renderer.splat();
    }
}
