const PixelBuffer = @This();

pub const width: u32 = 320;
pub const height: u32 = 180;

pixels: [width * height]u32,

pub fn init() PixelBuffer {
    return .{ .pixels = [_]u32{0} ** (width * height) };
}

pub inline fn setPixel(self: *PixelBuffer, x: usize, y: usize, color: u32) void {
    self.pixels[y * width + x] = color;
}
