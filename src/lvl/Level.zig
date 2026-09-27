const Level = @This();

const Tile = @import("Tile.zig");
const std = @import("std");
const Renderer = @import("../gfx/Renderer.zig");

pub const width: usize = 32;
pub const height: usize = 32;

tiles: [width * height]usize,

pub fn init() Level {
    var tiles: [width * height]usize = [_]usize{0} ** (width * height);

    for (3..12) |y| {
        for (5..18) |x| {
            tiles[y * width + x] = 1;
        }
    }

    return .{
        .tiles = tiles
    };
}

pub fn blit(self: *const Level, renderer: *Renderer) void {
    var y: i32 = 0;
    while (y < 30) : (y += 1) {
        var x: i32 = 0;
        while (x < 30) : (x += 1) {
            Tile.registry.tiles.items[self.tileAt(@intCast(x), @intCast(y))].blit(renderer, x * 16, y * 16);
        }
    }
}

pub inline fn tileAt(self: *const Level, x: usize, y: usize) usize {
    return self.tiles[y * width + x];
}