const Palette = @This();

const color = @import("color.zig");

const channels: usize = 6;

shades: [channels * channels * channels]u32,

pub fn init() Palette {
    var shades: [channels * channels * channels]u32 = [_]u32{0} ** (channels * channels * channels);

    var i: usize = 0;
    var r: usize = 0;
    while (r < channels) : (r += 1) {
        var g: usize = 0;
        while (g < channels) : (g += 1) {
            var b: usize = 0;
            while (b < channels) : (b += 1) {
                var rr = mapColor(r);
                var gg = mapColor(g);
                var bb = mapColor(b);

                const luminance: f32 = (rr * 30.0 + gg * 59.0 + bb * 11.0) / 100.0;

                applyLuminance(&rr, luminance);
                applyLuminance(&gg, luminance);
                applyLuminance(&bb, luminance);

                shades[i] = (0xFF << 24) | (@as(u32, @intFromFloat(rr)) << 16) | (@as(u32, @intFromFloat(gg)) << 8) | (@as(u32, @intFromFloat(bb)));

                i += 1;
            }
        }
    }

    return .{ .shades = shades };
}

inline fn applyLuminance(c: *f32, luminance: f32) void {
    c.* += luminance;
    c.* /= 2.0;
    c.* *= 230.0 / 255.0;
    c.* += 10.0;
}

/// Spreads colors out evenly to get a wide variety of shades
inline fn mapColor(c: usize) f32 {
    return @as(f32, @floatFromInt(c * 255)) / (channels - 1);
}

pub inline fn palettize(r: usize, g: usize, b: usize) usize {
    return toPaletteIdx(mapColor(r)) * (channels * channels) +
        toPaletteIdx(mapColor(g)) * channels +
        toPaletteIdx(mapColor(b));
}

pub inline fn palettizeArray(array: [color.channels]usize) usize {
    return palettize(array[0], array[1], array[2]);
}

inline fn toPaletteIdx(c: f32) u8 {
    if (c < 0) return 0;

    return @as(u8, @intFromFloat(@rem((c * 100.0), 10.0) + @rem((c * 10.0), 10.0) + @rem(c, 10.0)));
}
