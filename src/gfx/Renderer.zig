const Renderer = @This();

const c = @import("c");

const PixelBuffer = @import("PixelBuffer.zig");
const Palette = @import("Palette.zig");
const Texture = @import("Texture.zig");
const math = @import("../math.zig");

screen: *c.SDL_Texture,
renderer:*c.SDL_Renderer,
pixel_buffer: PixelBuffer,
palette: Palette,

pub fn init(window: *c.SDL_Window) !Renderer {
    const renderer = c.SDL_CreateRenderer(window, null) orelse return error.FailedToCreateRenderer;

    const screen = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_ARGB8888, c.SDL_TEXTUREACCESS_STREAMING, PixelBuffer.width, PixelBuffer.height) orelse return error.FailedToCreateScreenTexture;
    _ = c.SDL_SetTextureScaleMode(screen, c.SDL_SCALEMODE_NEAREST);

    return .{
        .renderer = renderer,
        .screen = screen,
        .palette = .init(),
        .pixel_buffer = .init(),
    };
}

pub fn deinit(self: *const Renderer) void {
    c.SDL_DestroyTexture(self.screen);
    c.SDL_DestroyRenderer(self.renderer);
}

pub fn flush(self: *Renderer) void {
    _ = c.SDL_RenderClear(self.renderer);

    @memset(&self.pixel_buffer.pixels, 0);
}

pub fn splat(self: *Renderer) void {
    var buffer: ?*anyopaque = null;
    var pitch: i32 = undefined;
    _ = c.SDL_LockTexture(self.screen, null, &buffer, &pitch);

    @memcpy(@as([*]u32, @ptrCast(@alignCast(buffer))), &self.pixel_buffer.pixels);

    c.SDL_UnlockTexture(self.screen);

    _ = c.SDL_RenderTexture(self.renderer, self.screen, null, null);

    _ = c.SDL_RenderPresent(self.renderer);
}

pub fn blitTexture(self: *Renderer, texture_id: usize, src: math.Rect(u32), dst: math.Point(i32), colors: [Texture.channels]usize) void {
    const texture = Texture.registry.textures.items[texture_id];

    _ = dst;
    for (0..src.h) |y| {
        for (0..src.w) |x| {
            const pixel = texture.pixelAt(x, y);

            if (pixel == Texture.transparent_pixel) {
                continue;
            }

            self.pixel_buffer.setPixel(x, y, self.palette.shades[colors[pixel]]);
        }
    }
}