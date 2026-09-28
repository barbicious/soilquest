const State = @This();

const std = @import("std");
const c = @import("c");

const Renderer = @import("gfx/Renderer.zig");
const Texture = @import("gfx/Texture.zig");
const Tile = @import("lvl/Tile.zig");
const Level = @import("lvl/Level.zig");
const Pawn = @import("Pawn.zig");
const Keyboard = @import("Keyboard.zig");

const max_ticks: f32 = 1.0 / 60.0;

renderer: Renderer,
level: Level,
window: *c.SDL_Window,

pub fn init(allocator: std.mem.Allocator, io: std.Io) !State {
    try Texture.Registry.init(io, allocator);
    try Tile.Registry.init(io, allocator);

    Keyboard.init();

    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        return error.FailedToInitSDL;
    }

    const window = c.SDL_CreateWindow("Soilquest", 1280, 720, 0) orelse return error.FailedToCreateWindow;

    return .{ .renderer = try .init(window), .window = window, .level = .init() };
}

pub fn deinit(self: *State, allocator: std.mem.Allocator) void {
    self.renderer.deinit();

    c.SDL_DestroyWindow(self.window);

    c.SDL_Quit();

    Texture.registry.deinit(allocator);
    Tile.registry.deinit(allocator);
}

pub fn run(self: *State, io: std.Io) void {
    var running = true;

    var event: c.SDL_Event = undefined;

    var player: Pawn = .init(.player, 20, 16);

    var last_tick = std.Io.Clock.real.now(io);
    var accumulated: f32 = 0.0;

    while (running) {
        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) {
                running = false;
            }
        }

        const now_tick = std.Io.Clock.real.now(io);
        const dt = @as(f32, @floatFromInt(last_tick.durationTo(now_tick).nanoseconds)) / 1_000_000_000.0;
        last_tick = now_tick;

        accumulated += dt;

        while (accumulated >= max_ticks) {
            Keyboard.keyboard.tick();

            player.tick();

            accumulated -= max_ticks;
        }

        self.renderer.flush();

        self.level.blit(&self.renderer);
        player.blit(&self.renderer);

        self.renderer.splat();
    }
}
