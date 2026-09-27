const State = @This();

const std = @import("std");
const c = @import("c");

const Renderer = @import("gfx/Renderer.zig");
const Texture = @import("gfx/Texture.zig");
const Tile = @import("lvl/Tile.zig");
const Level = @import("lvl/Level.zig");

renderer: Renderer,
level: Level,
window: *c.SDL_Window,

pub fn init(io: std.Io, allocator: std.mem.Allocator) !State {
    try Texture.Registry.init(io, allocator);
    try Tile.Registry.init(io, allocator);

    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        return error.FailedToInitSDL;
    }

    const window = c.SDL_CreateWindow("Soilquest", 1280, 720, 0) orelse return error.FailedToCreateWindow;

    return .{
        .renderer = try .init(window),
        .window = window,
        .level = .init()
    };
}

pub fn deinit(self: *State, allocator: std.mem.Allocator) void {
    self.renderer.deinit();

    c.SDL_DestroyWindow(self.window);

    c.SDL_Quit();

    Texture.registry.deinit(allocator);
    Tile.registry.deinit(allocator);
}

pub fn run(self: *State) void {
    var running = true;

    var event: c.SDL_Event = undefined;

    while (running) {
        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) {
                running = false;
            }
        }

        self.renderer.flush();

        self.level.blit(&self.renderer);

        self.renderer.splat();
    }
}