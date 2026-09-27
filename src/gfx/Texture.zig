pub const Texture = @This();

const c = @import("c");
const std = @import("std");

pub var registry: Registry = undefined;

pub const channels: usize = 4;

pub const transparent_pixel: u8 = 255;

pixels: [*]u8,
width: i32,
height: i32,

pub fn init(path: [*c]const u8) !Texture {
    var ch: i32 = undefined;

    var width: i32 = undefined;
    var height: i32 = undefined;
    var pixels = c.stbi_load(path, &width, &height, &ch, 1) orelse return error.FailedToLoadTexture;

    for (0..(@as(usize, @intCast(width * height)))) |i| {
        if (pixels[i] == 0) {
            pixels[i] = transparent_pixel;
        } else {
            pixels[i] /= 64;
        }
    }

    return .{
        .width = width,
        .height = height,
        .pixels = pixels,
    };
}

pub fn deinit(self: *const Texture) void {
    c.stbi_image_free(self.pixels);
}

pub inline fn pixelAt(self: *const Texture, x: usize, y: usize) u8 {
    return self.pixels[y * @as(usize, @intCast(self.width)) + x];
}

pub const Registry = struct {
    names: std.StringHashMap(usize),
    textures: std.ArrayList(Texture),

    pub fn init(io: std.Io, allocator: std.mem.Allocator) !void {
        var names: std.StringHashMap(usize) = .init(allocator);
        var textures: std.ArrayList(Texture) = .empty;

        var texture_dir = try std.Io.Dir.cwd().openDir(io, "res/textures", .{ .iterate = true });

        var iter = texture_dir.iterate();
        while (try iter.next(io)) |entry| {
            if (entry.kind == .file) {
                const file_name: [:0]const u8 = try allocator.dupeSentinel(u8, try std.mem.concat(allocator, u8, &.{ "res/textures/", entry.name }), 0);
                defer allocator.free(file_name);

                var split = std.mem.splitAny(u8, entry.name, ".");
                const name = try allocator.dupe(u8, split.first());
                errdefer allocator.free(name);

                try names.put(name, textures.items.len);

                try textures.append(allocator, try .init(file_name));
            }
        }

        registry = .{
            .names = names,
            .textures = textures,
        };
    }

    pub fn deinit(self: *Registry, allocator: std.mem.Allocator) void {
        for (self.textures.items) |texture| {
            texture.deinit();
        }

        self.textures.deinit(allocator);

        var key_iter = self.names.keyIterator();
        while (key_iter.next()) |key| {
            allocator.free(key.*);
        }

        self.names.deinit();
    }
};
