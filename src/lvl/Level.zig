const Level = @This();

const Tile = @import("Tile.zig");
const std = @import("std");
const Renderer = @import("../gfx/Renderer.zig");

pub const width: usize = 10;
pub const height: usize = 10;

tiles: [width * height]usize,

pub fn init() Level {
    var tiles: [width * height]usize = [_]usize{0} ** (width * height);

    tiles[0] = 1;


    return .{ .tiles = tiles };
}

pub fn blit(self: *const Level, renderer: *Renderer) void {
    var y: i32 = 0;
    while (y < width) : (y += 1) {
        var x: i32 = 0;
        while (x < height) : (x += 1) {
            Tile.registry.tiles.items[self.tileAt(@intCast(x), @intCast(y))].blit(renderer, x * Tile.width, y * Tile.height);
        }
    }
}

pub inline fn tileAt(self: *const Level, x: usize, y: usize) usize {
    return self.tiles[y * width + x];
}
