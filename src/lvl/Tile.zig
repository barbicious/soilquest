const Tile = @This();

const std = @import("std");

const Texture = @import("../gfx/Texture.zig");
const color = @import("../gfx/color.zig");
const Palette = @import("../gfx/Palette.zig");
const Renderer = @import("../gfx/Renderer.zig");

pub var registry: Registry = undefined;

pub const width: i32 = 16;
pub const height: i32 = 16;

pub const NeighborsCheck = enum {
    zero,
    four,
    eight,
};

pub const Payload = struct {
    name: []const u8,
    colors: [Texture.channels][color.channels]usize,
    texture_name: []const u8,
};

id: usize,
colors: [Texture.channels]usize,
texture_id: usize,

pub fn init(payload: Payload, id: usize) Tile {
    std.log.debug("{any}", .{Texture.registry.names.contains("liquid")});
    return .{ .id = id, .colors = [_]usize{
        Palette.palettizeArray(payload.colors[0]),
        Palette.palettizeArray(payload.colors[1]),
        Palette.palettizeArray(payload.colors[2]),
        Palette.palettizeArray(payload.colors[3]),
    }, .texture_id = Texture.registry.names.get(payload.texture_name).? };
}

pub fn blit(self: *const Tile, renderer: *Renderer, x: i32, y: i32) void {
    renderer.blitTexture(self.id, .{
        .x = 0,
        .y = 0,
        .w = 8,
        .h = 8,
    }, .{
        .x = x,
        .y = y,
    }, self.colors);

    renderer.blitTexture(self.id, .{
        .x = 16,
        .y = 0,
        .w = 8,
        .h = 8,
    }, .{
        .x = x + 8,
        .y = y,
    }, self.colors);

    renderer.blitTexture(self.id, .{
        .x = 0,
        .y = 16,
        .w = 8,
        .h = 8,
    }, .{
        .x = x,
        .y = y + 8,
    }, self.colors);

    renderer.blitTexture(self.id, .{
        .x = 16,
        .y = 16,
        .w = 8,
        .h = 8,
    }, .{
        .x = x + 8,
        .y = y + 8,
    }, self.colors);
}

pub const Registry = struct {
    names: std.StringHashMap(usize),
    tiles: std.ArrayList(Tile),

    pub fn init(io: std.Io, allocator: std.mem.Allocator) !void {
        var names: std.StringHashMap(usize) = .init(allocator);
        var tiles: std.ArrayList(Tile) = .empty;

        var tile_dir = try std.Io.Dir.cwd().openDir(io, "res/tiles", .{ .iterate = true });

        var iter = tile_dir.iterate();

        while (try iter.next(io)) |entry| {
            if (entry.kind == .file) {
                const src: [:0]const u8 = try allocator.dupeSentinel(u8, try std.Io.Dir.readFileAlloc(tile_dir, io, entry.name, allocator, .unlimited), 0);
                defer allocator.free(src);

                const tile_id = tiles.items.len;

                const payload = try std.zon.parse.fromSliceAlloc(Payload, allocator, src, null, .{});
                try names.put(payload.name, tile_id);

                try tiles.append(allocator, .init(payload, tile_id));
            }
        }

        registry = .{
            .names = names,
            .tiles = tiles,
        };
    }

    pub fn deinit(self: *Registry, allocator: std.mem.Allocator) void {
        self.tiles.deinit(allocator);
        self.names.deinit();
    }
};
