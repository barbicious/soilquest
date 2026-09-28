const Pawn = @This();

const math = @import("math.zig");
const c = @import("c");
const std = @import("std");

const Texture = @import("gfx/Texture.zig");
const Renderer = @import("gfx/Renderer.zig");
const Palette = @import("gfx/Palette.zig");
const Keyboard = @import("Keyboard.zig");
const Level = @import("lvl/Level.zig");
const Tile = @import("lvl/Tile.zig");

pub const Type = enum {
    player,
};

type: Type,
pos: math.Point(i32),
texture_id: usize,
colors: [Texture.channels]usize,

pub fn init(@"type": Type, x: i32, y: i32) Pawn {
    const texture_id = switch (@"type") {
        .player => Texture.registry.names.get("player").?,
    };

    const colors = switch (@"type") {
        .player => [_]usize{
            Palette.palettize(1, 1, 1),
            Palette.palettize(5, 4, 1),
            Palette.palettize(3, 2, 1),
            Palette.palettize(4, 3, 2),
        },
    };

    return .{
        .type = @"type",
        .pos = .{ .x = x, .y = y },
        .texture_id = texture_id,
        .colors = colors,
    };
}

pub fn blit(self: *Pawn, renderer: *Renderer) void {
    renderer.blitTexture(self.texture_id, .{
        .x = 0,
        .y = 0,
        .w = 16,
        .h = 16,
    }, self.pos, self.colors);
}

pub fn tick(self: *Pawn) void {
    if (Keyboard.keyboard.isKeyDown(c.SDL_SCANCODE_A)) {
        self.pos.x -= 1;
    }

    if (Keyboard.keyboard.isKeyDown(c.SDL_SCANCODE_D)) {
        self.pos.x += 1;
    }

    self.pos.x = std.math.clamp(self.pos.x, 0, @as(i32, @intCast((Level.width - 1) * Tile.width)));

    if (Keyboard.keyboard.isKeyDown(c.SDL_SCANCODE_W)) {
        self.pos.y -= 1;
    }

    if (Keyboard.keyboard.isKeyDown(c.SDL_SCANCODE_S)) {
        self.pos.y += 1;
    }

    self.pos.y = std.math.clamp(self.pos.y, 0, @as(i32, @intCast((Level.height - 1) * Tile.height)));
}